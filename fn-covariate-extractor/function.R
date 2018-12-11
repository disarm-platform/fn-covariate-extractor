library(raster)
library(rworldmap)
library(RANN)
library(sf)
library(downloader)
library(jsonlite)

source('utils.R')

# TODO: Need to document what `input` expects to contain
# input$coords array of lat/lng objects: coordinates to calculate for
# input$layer_names string array: list of layer names to include (from where?)
# input$elev boolean: include the 'elevation' layer
# input$dist_to_water boolean: include the 'distance to water' layer

extract_covariate <- function(input_string) {

  input = jsonlite::fromJSON(input_string)
  message(paste("\nReceived: ", input_string, "\n"))
  
  # Function to retrieve covariates for a set of
  # spatial queries (points or polygons)
  coords <- cbind(input$coords$lng, input$coords$lat)
  extracted_values <- list()
  
  # If layers have been specified then get them
  # and extract values
  if (!is.null(input$layer_name)) {
    # ID which layers to get
    layers <- input$layer_name
    
    # get layers
    layers_raster <- raster::getData('worldclim', var = 'bio', res = 10)[[layers]]
    
    # Extract values
    extracted_values <- as.list(data.frame(raster::extract(layers_raster, coords)))
    names(extracted_values) <- as.character(layers)
  } else {
    # TODO: Do what if there's no input$layer_name?
    # Do we want to invert the logic and have this right at the top, so we return 
    # an error immediately if there's no layer_name, or stick with returning an empty list now?
  }
  
  # If elev=TRUE then get elev data
  # Get elevation data
  country <- as.character(coords2country(coords)[1])
  
  if (input$elev == TRUE) {
    elev <- raster::getData('alt', country = country)
    extracted_values$elev <- raster::extract(elev, coords)
  }
  
  if (input$dist_to_water == TRUE) {
    # Download and load in data
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
  
  # print a string
  print(jsonlite::toJSON(extracted_values))
  
}
