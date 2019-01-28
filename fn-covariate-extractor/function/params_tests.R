function(params) {

  ref_params <- c(
    paste0("bioclim", 1:19),
    "elev_m",
    "dist_to_water_m"
  )

  
  if(sum(!(params$layer_names %in% ref_params)) > 0){
    wrong_param <- params$layer_names[which(!(params$layer_names %in% ref_params))]
    stop(paste0("Parameter '", wrong_param, "' is not allowed. Check function specs for valid parameters. "))
  }
  
  if(!( geojsonlint::geojson_lint(as.json(params$points)))){
    stop("Parameter 'points' is not valid GeoJSON")
  }
  
}