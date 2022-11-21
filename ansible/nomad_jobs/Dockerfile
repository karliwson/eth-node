# Dockerfile for a minimal PoC erigon image: kakafka/erigon:latest
# Author: Kaká Oliveira (kakafka)

# Build stage
FROM alpine:3.16 AS build

WORKDIR /build

RUN set -ex && \
    wget https://github.com/ledgerwatch/erigon/releases/download/v2.30.0/erigon_2.30.0_linux_amd64.tar.gz && \
    tar -xvf erigon_2.30.0_linux_amd64.tar.gz -C ./

# Final stage
FROM gcr.io/distroless/base-debian11 AS final

COPY --from=build /build/erigon /usr/local/bin/

VOLUME /data

EXPOSE 8545 8551 8546 30303 30303/udp 42069 42069/udp 8080 9090 6060

CMD ["erigon", "--datadir=/data", "--chain=ropsten"]
