# fn-covariate-extractor
Give us a bunch of GeoJSON points and a list of layers, and we'll give you back the values of each layer for each point.

## Parameters

JSON object containing:

- `points` {GeoJSON Points FeatureCollection (or URL)} Points at which to extract covariate values
- `layer_names` {Array of string} array: list of layer names to include (from list below)

## Constraints

- maximum number of points/features
- maximum number of layers is XX
- can only include points within a single country

## Response

Input GeoJSON FeatureCollection with additional values added.


## Layer names
`bioclim1` to `bioclim19` index, corresponding to BioClim layer (http://www.worldclim.org/bioclim)

`elev_m` - elevation in metres (CGIAR-SRTM 90 m resolution aggregated to 1km - http://srtm.csi.cgiar.org/)

`dist_to_water_m` - 'distance to water' in metres layer from Digital Chart of the World (available via http://www.diva-gis.org/gdata)
	

