

library(raster)
library(rworldmap)
library(RANN)
library(sf)
library(downloader)
library(jsonlite)

coords2country = dget('function/coords2country.R')

handle_layer = function(points, layer_name, country) {
  if (layer_name %in% paste0("b", 1:19)) {
    return(handle_bioclim(points, layer_name))
  } else if (layer_name == "elev") {
    return(handle_elev(points, country))
  } else if (layer_name == "dist_to_water") {
    return(handle_dist_to_water(points, country))
  } else {
    stop(paste('Unknown layer name', layer_name))
  }
}

handle_bioclim = function(points, layer_name) {
  layer = as.numeric(layer)
  layers_raster <-
    raster::getData('worldclim', var = 'bio', res = 10)[[layer]]
  
  # Extract values
  extracted_values <-
    as.list(data.frame(raster::extract(layers_raster, coords)))
  names(extracted_values) <- as.character(layer)
  points$elev = extracted_values
  return(points)
}

handle_elev = function(points, country) {
  elev <- raster::getData('alt', country = country)
  coords <- st_coordinates(points)
  points$elev <- raster::extract(elev, coords)
  return(points)
}

handle_dist_to_water = function(points, country) {
  return(points)
  # download(
  #   url = paste0(
  #     "http://biogeo.ucdavis.edu/data/diva/wat/",
  #     country,
  #     "_wat.zip"
  #   ),
  #   paste0("water", country, ".zip"),
  #   mode = "wb"
  # )
  # outDir <-
  #   paste0(getwd(), "/water", country) # Define the folder where the zip file should be unzipped to
  # unzip(paste0("water", country, ".zip"), exdir = outDir)
  # water_bodies <-
  #   st_read(
  #     dsn = paste0(getwd(), "/water", country),
  #     layer = paste0(country, "_water_areas_dcw")
  #   )
  
  # # get coordinates
  # water_coords <- st_coordinates(st_geometry(water_bodies))[, 1:2]
  
  # # Calc dist to nearest
  # extracted_values$dist_to_water <-
  #   as.vector(nn2(water_coords, coords, k = 1)$nn.dists)
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

