library(jsonlite)
library(geojsonio)

check_params = dget('function/params_tests.R')
run_function = dget('function/function.R')

main = function () {
  tryCatch({
    # reads STDIN as JSON, return error if any problems
    # params = fromJSON(readLines(file("stdin")))
    params = fromJSON(readLines(file("function/test_req.json")))
    
    
    # checks for existence of required parameters, return error if any problems
    # checks types/structure of all parameters, return error if any problems
    check_params(params)

    # if any parameters refer to remote files, try to download and 
    # replace parameter with local/temp file reference, return error if any problems
    retrieve_remote_files(params)
    
    # run the function with parameters, 
    # return error if any problems, return success if succeeds      
    function_response = run_function(params)
    return(handle_success(function_response))
  }, error = function(e) {
    return(handle_error(e))
  })
}

retrieve_remote_files = function(params) {
  # TODO: Write when we have a specific need
  # check if any params are strings that start with 'http' (any case)
  # tryCatch retrieve that file, 
  #   stop() if problems, 
  #   otherwise, write to temp disk, replace parameter with temp filename
}

handle_error = function(error) {
  type = 'error'
  function_response = as.json(list(type = unbox(type), result = unbox(as.character(error))))
  return(write(function_response, stdout()))
}

handle_success = function(result) {
  type = 'success'
  function_response = as.json(list(type = unbox(type), result = result))
  return(write(function_response, stdout()))
}

main()
