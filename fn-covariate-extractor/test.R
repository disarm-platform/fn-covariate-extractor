# Test covariate extractor

source('function.R')

raw_string <-
  '{
    "layer_names": [
      1,
      5
    ],
    "elev": true,
    "dist_to_water": true,
    "coords": [
      {
        "lat": -6.1683,
        "lng": 39.3335
      },
      {
        "lat": -5.9209,
        "lng": 39.2909
      }
    ]
  }'

# Run function
extract_covariate(raw_string)
