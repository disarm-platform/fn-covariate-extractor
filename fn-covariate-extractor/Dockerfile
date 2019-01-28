FROM rocker/geospatial

RUN mkdir -p /home/app

COPY ./fwatchdog /usr/bin
RUN chmod +x /usr/bin/fwatchdog

WORKDIR /app

COPY function/install_packages.R function/
RUN Rscript function/install_packages.R

# Populate example here - i.e. "cat", "sha512sum" or "node index.js"
ENV fprocess="Rscript function/main.R"
# Set to true to see request in function logs
ENV write_debug="false"

EXPOSE 8080

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1
CMD [ "fwatchdog" ]
