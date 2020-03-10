library(raster)
library(rworldmap)
library(RANN)
library(sf)
library(downloader)
library(jsonlite)
library(geosphere)

coords2country = dget('function/coords2country.R')

handle_layer = function(points, layer_name, country, ref_raster) {
  if (layer_name %in% paste0("bioclim", 1:19)) {
    return(handle_bioclim(points, layer_name, ref_raster))
  } else if (layer_name == "elev_m") {
    return(handle_elev_m(points, country, ref_raster))
  } else if (layer_name == "dist_to_water_m") {
    return(handle_dist_to_water_m(points, country))
  } else if (layer_name == "dist_to_road_m") {
    return(handle_dist_to_road_m(points))
  } else {
    stop(paste('Unknown layer name', layer_name))
  }
}

handle_bioclim = function(points, layer_name, ref_raster) {
  layer = as.numeric(substr(layer_name, 8, 10))
  layers_raster <-
    raster::getData('worldclim', var = 'bio', res = 5)[[layer]]
  
  # resample
  layers_raster <- resample(layers_raster, ref_raster)
  
  # Extract values
  extracted_values <-
    as.list(data.frame(raster::extract(layers_raster, st_coordinates(points))))
  points[layer_name] = extracted_values
  return(points)
}

handle_elev_m = function(points, country, ref_raster) {
  elev_m <- raster::getData('alt', country = country)
  
  # resample
  elev_m <- resample(elev_m, ref_raster)
  
  coords <- st_coordinates(points)
  points$elev_m <- raster::extract(elev_m, coords)
  
  # If any points are in the sea, they will appear as NA,
  # so recode to 0
  points$elev_m[is.na(points$elev_m)] <- 0
  return(points)
}

handle_dist_to_water_m = function(points, country) {
  filename = paste0("water", country, ".zip")
  
  download(
    url = paste0(
      "http://biogeo.ucdavis.edu/data/diva/wat/",
      country,
      "_wat.zip"
    ),
    filename,
    mode = "wb"
  )
  outDir <-
    paste0(getwd(), "/water", country) # Define the folder where the zip file should be unzipped to
  
  unzip(paste0("water", country, ".zip"), exdir = outDir)
  
  water_bodies <-
    st_read(
      dsn = paste0(getwd(), "/water", country),
      layer = paste0(country, "_water_areas_dcw"),
      quiet = T # Definitely quiet
    )
  
  rivers <-
    st_read(
      dsn = paste0(getwd(), "/water", country),
      layer = paste0(country, "_water_lines_dcw"),
      quiet = T # Definitely quiet
    )
  
  
  # get coordinates
  waterbody_coords <-
    st_coordinates(st_geometry(water_bodies))[, 1:2]
  river_coords <- st_coordinates(st_geometry(rivers))[, 1:2]
  water_coords <- rbind(waterbody_coords, river_coords)
  
  # If no water data, return NA
  if (nrow(water_coords) == 0) {
    return(points$dist_to_water_m <- NA)
  }
  
  # Calc dist to nearest
  coords <- st_coordinates(points)
  closest <- nn2(water_coords, coords, k = 1)$nn.idx
  points$dist_to_water_m  <-
    round(distGeo(coords, water_coords[closest,]), 0)
  
  return(points)
}

handle_dist_to_road_m <- function(points) {
  download(
    url = paste0(
      "https://storage.googleapis.com/ds-faas/algo_test_data/fn-covariate-extractor/road_coords_global_combined.RData"
    ),
    "road_coords_global_combined.RData"
  )
  
  load("road_coords_global_combined.RData")
  
  # Trim roads
  points_bbox <- st_bbox(points)
  points_bbox_buffer <- points_bbox + c(-1, -1, 1, 1)
  road_coords_global_crop <- subset(
    road_coords_global_combined,
    road_coords_global_combined$X > points_bbox_buffer[1] &
      road_coords_global_combined$X <
      points_bbox_buffer[3] &
      road_coords_global_combined$Y >
      points_bbox_buffer[2] &
      road_coords_global_combined$Y <
      points_bbox_buffer[4]
  )
  
  # If no roads, return NA
  if (nrow(road_coords_global_crop) == 0) {
    return(points$dist_to_road_m <- NA)
  }
  
  # Calc dist to nearest
  coords <- st_coordinates(points)
  closest <- nn2(road_coords_global_crop, coords, k = 1)$nn.idx
  points$dist_to_road_m  <-
    round(distGeo(coords, road_coords_global_crop[closest,]), 0)
  
  return(points)
}


function(params) {
  if (substr(params$points, 1, 4) == "http") {
    points = st_read(params$points, quiet = T)
  } else {
    points = st_read(rjson::toJSON(params$points), quiet = T)
    #points = st_read(as.json(params$points), quiet = T)
  }
  layer_names = tolower(params$layer_names)
  country = as.character(coords2country(st_coordinates(points))[1])
  
  # Define resolution
  ref_raster <- raster::getData('alt', country = country)
  if (params$resolution > 1) {
    ref_raster <- aggregate(ref_raster, params$resolution)
  }
  
  for (layer_name in layer_names) {
    points = handle_layer(points, layer_name, country, ref_raster)
  }
  return(geojson_list(points))
}
