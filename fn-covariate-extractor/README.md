## Example
`docker run -it --mount type=bind,source=(pwd),target=/src
disarm/geospatial-plus bash` (or whatever the image is named)

In the connected container, `cd` to `src/fn-covariate-extrator` 

Run something like `echo '{ "layer_names": [ 1, 5 ], "elev": true,
"dist_to_water": true, "coords": [ { "lat": -6.1683, "lng": 39.3335 }, {
"lat": -5.9209, "lng": 39.2909 } ] }' | Rscript run.R`

