#!/bin/sh

VERSION="1.0.0"
REVISION=$(git rev-parse --short HEAD)
DATE=$(date --iso-8601)

docker build . \
    --tag dns:$VERSION \
    --tag dns:latest \
    --label "org.opencontainers.created=$DATE" \
    --label "org.opencontainers.version=$VERSION" \
    --label "org.opencontainers.revision=$REVISION"
