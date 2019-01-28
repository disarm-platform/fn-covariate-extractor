coords2country = function(points) {
  countriesSP <- getMap(resolution = 'low')
  #setting CRS directly to that from rworldmap
  pointsSP = SpatialPoints(points, proj4string = CRS(proj4string(countriesSP)))
  
  # use 'over' to get indices of the Polygons object containing each point
  indices = over(pointsSP, countriesSP)
  
  # return the ADMIN names of each country
  #indices$ADMIN
  indices$ISO3 # returns the ISO3 code
}