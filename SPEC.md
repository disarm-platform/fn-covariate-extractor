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

From BioClim (insert link/docs)
	- index

Also:
	- `elev` - elevation from XX source
	- `dist_to_water` 'distance to water' layer from XX source
