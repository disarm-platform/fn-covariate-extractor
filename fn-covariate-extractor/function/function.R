
library(raster)
library(rworldmap)
library(RANN)
library(sf)
library(downloader)
library(jsonlite)

source('utils.R')


function(params) {
  points = st_read(params$points)
  layer_names = params$layer_names
  country = as.character(coords2country(coords)[1])

  for(layer_name in layer_names) {
    handle_layer(layer_name, country)
  }

  return(points)
}


handle_layer = function(layer_name, country) {

  if (layer_name is bioclim) {
    handle_bioclim(layer_name)
  } else if (layer_name is elev) {
    handle_elev(country)
  } else if (layer_name is dist_to_water) {
    handle_dist_to_water(country)
  } else {
    # handle this case
    stop(paste('Unknown layer name', layer_name))
  }

}


handle_bioclim = function(layer_name) {
    layers_raster <- raster::getData('worldclim', var = 'bio', res = 10)[[layers]]
    
    # Extract values
    extracted_values <- as.list(data.frame(raster::extract(layers_raster, coords)))
    names(extracted_values) <- as.character(layers)
    points$elev = extracted_values
}

handle_elev = function(country) {
    elev <- raster::getData('alt', country = country)
    points$elev <- raster::extract(elev, points)
}

handle_dist_to_water = function(country) {
      download(
      url = paste0(
        "http://biogeo.ucdavis.edu/data/diva/wat/",
        country,
        "_wat.zip"
      ),
      paste0("water", country, ".zip"),
      mode = "wb"
    )
    outDir <-
      paste0(getwd(), "/water", country) # Define the folder where the zip file should be unzipped to
    unzip(paste0("water", country, ".zip"), exdir = outDir)
    water_bodies <-
      st_read(
        dsn = paste0(getwd(), "/water", country),
        layer = paste0(country, "_water_areas_dcw")
      )
    
    # get coordinates
    water_coords <- st_coordinates(st_geometry(water_bodies))[, 1:2]
    
    # Calc dist to nearest
    extracted_values$dist_to_water <-
      as.vector(nn2(water_coords, coords, k = 1)$nn.dists)
}


  # Function to retrieve covariates for a set of
  # spatial queries (points or polygons)
  # coords <- cbind(input$coords$lng, input$coords$lat)
  # extracted_values <- list()
  
  # If layers have been specified then get them
  # and extract values
  
  # if (!is.null(input$layer_names)) {
  #   # ID which layers to get
  #   layers <- input$layer_name
    
  #   # get layers
  #   # layers_raster <- raster::getData('worldclim', var = 'bio', res = 10)[[layers]]
    
  #   # # Extract values
  #   # extracted_values <- as.list(data.frame(raster::extract(layers_raster, coords)))
  #   # names(extracted_values) <- as.character(layers)
  # } else {
  #   # TODO: Do what if there's no input$layer_name?
  #   # Do we want to invert the logic and have this right at the top, so we return 
  #   # an error immediately if there's no layer_name, or stick with returning an empty list now?
  # }
  
  # # If elev=TRUE then get elev data
  # # Get elevation data
  # country <- as.character(coords2country(coords)[1])
  
  # if (input$elev == TRUE) {
  #   elev <- raster::getData('alt', country = country)
  #   extracted_values$elev <- raster::extract(elev, coords)
  # }
  
  # if (input$dist_to_water == TRUE) {
  #   # Download and load in data
  #   # download(
  #   #   url = paste0(
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
  # }
  
  # print a string
  # print(jsonlite::toJSON(extracted_values))
  
