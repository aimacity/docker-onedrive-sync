# Multi-stage build - See https://docs.docker.com/engine/userguide/eng-image/multistage-build

FROM dlanguage/dmd as dmd

RUN apt-get update && apt-get install -y git make libcurl4-openssl-dev libsqlite3-dev  pkg-config

RUN   git clone https://github.com/abraunegg/onedrive.git \
  && cd onedrive \
  && ./configure \
  && make \
  && make install

# Primary image
FROM aimacity/s6-debian:latest

RUN apt-get update \
  && apt-get install -y gosu libcurl3 libsqlite3-0 \
  && apt-get autoremove &&  apt clean \
  && mkdir  -p /OneDrive \
  && chown aima:aima /OneDrive

COPY --from=dmd /usr/local/bin/onedrive /usr/local/bin/onedrive
COPY root /

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS 2

CMD ["/start.sh"]
