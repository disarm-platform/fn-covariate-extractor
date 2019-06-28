library(raster)
library(rworldmap)
library(RANN)
library(sf)
library(downloader)
library(jsonlite)
library(geosphere)

coords2country = dget('function/coords2country.R')

handle_layer = function(points, layer_name, country) {
  browser()
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
    raster::getData('worldclim', var = 'bio', res = 5)[[layer]]
  
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
  
  # If any points are in the sea, they will appear as NA, 
  # so recode to 0
  points$elev_m[is.na(points$elev_m)] <- 0
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
  
  rivers <-
    st_read(
      dsn = paste0(getwd(), "/water", country),
      layer = paste0(country, "_water_lines_dcw"),
      quiet = T # Definitely quiet
    )
    
  
  # get coordinates
  waterbody_coords <- st_coordinates(st_geometry(water_bodies))[, 1:2]
  river_coords <- st_coordinates(st_geometry(rivers))[, 1:2]
  water_coords <- rbind(waterbody_coords, river_coords)
  
  # If no water data, return NA
  if(nrow(water_coords)==0){
    return(points$dist_to_water_m <- NA)
  }
  
  # Calc dist to nearest
  coords <- st_coordinates(points)
  closest <- nn2(water_coords, coords, k = 1)$nn.idx
  points$dist_to_water_m  <- round(distGeo(coords, water_coords[closest,]), 0)

  return(points)
}

function(params) {

  if(substr(params$points,1,4)=="http"){
    points = st_read(params$points, quiet = T)
  }else{
  points = st_read(as.json(params$points), quiet = T)
  }
  layer_names = tolower(params$layer_names)
  country = as.character(coords2country(st_coordinates(points))[1])
  
  for (layer_name in layer_names) {
    points = handle_layer(points, layer_name, country)
  }
  return(geojson_list(points))
}

