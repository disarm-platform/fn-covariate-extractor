# fn-covariate-extractor
OpenFaas version of the covariate extractor. This algorithm extracts values of a curated set of raster layers at a set of points or polygons. See `SPECS.md` for more details.

## Clone template

Before building, need to clone the template: 
`faas template pull https://github.com/disarm-platform/faas-templates.git`


### OpenFaaS location
http://faas.srv.disarm.io/function/fn-covariate-extractor

### Running locally
echo $(cat "function/test_req.json") | Rscript main.R
