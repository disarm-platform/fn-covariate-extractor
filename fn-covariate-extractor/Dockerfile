FROM rocker/geospatial

RUN mkdir -p /home/app

ADD https://github.com/openfaas/faas/releases/download/0.9.6/fwatchdog /usr/bin
RUN chmod +x /usr/bin/fwatchdog

# # Add non root user
# RUN addgroup -S app && adduser app -S -G app

# RUN chown app /home/app

# WORKDIR /home/app

# USER app

RUN Rscript "install.packages(c('rworldmap', 'downloader', 'jsonlite'))"

# Populate example here - i.e. "cat", "sha512sum" or "node index.js"
ENV fprocess="Rscript "
# Set to true to see request in function logs
ENV write_debug="false"

EXPOSE 8080

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1
CMD [ "fwatchdog" ]
