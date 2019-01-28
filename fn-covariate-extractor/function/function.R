library(raster)
library(rworldmap)
library(RANN)
library(sf)
library(downloader)
library(jsonlite)
library(geosphere)

coords2country = dget('function/coords2country.R')

handle_layer = function(points, layer_name, country) {
  if (layer_name %in% paste0("bioclim", 1:19)) {
    return(handle_bioclim(points, layer_name))
  } else if (layer_name == "elev_m") {
    return(handle_elev_m(points, country))
  } else if (layer_name == "dist_to_water_m") {
    return(handle_dist_to_water_m(points, country))
  } else {
    stop(paste('Unknown layer name', layer_name))
  }
}

handle_bioclim = function(points, layer_name) {
  layer = as.numeric(substr(layer_name, 8, 10))
  layers_raster <-
    raster::getData('worldclim', var = 'bio', res = 10)[[layer]]
  
  # Extract values
  extracted_values <-
    as.list(data.frame(raster::extract(layers_raster, st_coordinates(points))))
  points[layer_name] = extracted_values
  return(points)
}

handle_elev_m = function(points, country) {
  elev_m <- raster::getData('alt', country = country)
  coords <- st_coordinates(points)
  points$elev_m <- raster::extract(elev_m, coords)
  return(points)
}

handle_dist_to_water_m = function(points, country) {
  filename = paste0("water", country, ".zip")

  if (!file.exists(filename)) {

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

  }

  water_bodies <-
    st_read(
      dsn = paste0(getwd(), "/water", country),
      layer = paste0(country, "_water_areas_dcw"),
      quiet = T # Definitely quiet
    )
    
  
  # get coordinates
  water_coords <- st_coordinates(st_geometry(water_bodies))[, 1:2]
  
  # Calc dist to nearest
  coords <- st_coordinates(points)
  closest <- nn2(water_coords, coords, k = 1)$nn.idx
  dist_m_matrix <- distm(coords, water_coords[closest,])
  points$dist_to_water_m <- round(apply(dist_m_matrix, 1, min),0)

  return(points)
}

function(params) {
  points = st_read(as.json(params$points), quiet = T)
  layer_names = tolower(params$layer_names)
  country = as.character(coords2country(st_coordinates(points))[1])
  
  for (layer_name in layer_names) {
    points = handle_layer(points, layer_name, country)
  }

  return(geojson_list(points))
}

