bucket_list = function() {
  
}

bucket_put = function() {
  
}

function(layer_name, country) {
  return(c(layer_name, country))
  # TODO: what about marking a download as 'started'?
  
  # return if layer_name or country don't match some requirments
  # e.g. must exist, layer_name must be within a list, country must have XX chars, etc
  
  # create zip_filename: e.g. SWZ_msk_alt.zip
  # construct zip_url for zip_filename
  
  # check if zip_filename exists in bucket
  # if exists: return zip_file to user
  # if not:
  # fetch zip_file from remote server using zip_url
  # store zip_file in bucket
  # return zip_file to user
}
