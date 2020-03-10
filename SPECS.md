# fn-covariate-extractor
Give us a bunch of GeoJSON points and a list of layers, and we'll give you back the values of each layer for each point.

## Parameters

JSON object containing:

- `points` {GeoJSON Points FeatureCollection} Points at which to extract covariate values
- `layer_names` {Array of string} array: list of layer names to include (from list below)
- `resolution` {integer} Optional resolution in km2 (>=1) to resample all covariates to before making extraction. Resmapling performed using bilinear interpolation. Defaults to 1.

### Note about `points`, `layer_names` and countries

If you're providing a list of `layer_names` to get covariates for, please note: we use for the first _Feature_ in `points` to determine the country, and then retrieve the relevant covariate layers for that country only. Points spanning multiple countries will only get covariates for the country in which the first point lies.

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

`dist_to_road_m` - 'distance to nearest road in metres using the [gRoads](https://sedac.ciesin.columbia.edu/data/set/groads-global-roads-open-access-v1) dataset
	
## Example input
An example JSON input can be found [here](https://raw.githubusercontent.com/disarm-platform/fn-covariate-extractor/master/fn-covariate-extractor/function/test_req.json)
