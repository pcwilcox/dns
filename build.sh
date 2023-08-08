#!/bin/sh

VERSION="1.0.0"
REVISION=$(git rev-parse --short HEAD)
DATE=$(date --iso-8601)

docker build . \
    --tag dns:$VERSION \
    --label "org.opencontainers.created=$DATE" \
    --label "org.opencontainers.version=$REVISION" \
    --label "org.opencontainers.revision=$DATE"
