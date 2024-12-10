#!/usr/bin/env bash

if [ -z "$PLATFORMS" ] || [ -z "$MACVTAP_IMAGE_TAGGED" ]; then
    echo "Error: PLATFORMS, and MACVTAP_IMAGE_TAGGED must be set."
    exit 1
fi

IFS=',' read -r -a PLATFORM_LIST <<< "$PLATFORMS"

BUILD_ARGS="-f cmd/Dockerfile -t $MACVTAP_IMAGE_TAGGED . --push"

if [ ${#PLATFORM_LIST[@]} -eq 1 ]; then
    docker build --platform "$PLATFORMS" $BUILD_ARGS
else
    ./hack/init-buildx.sh "$DOCKER_BUILDER"
    docker buildx build --platform "$PLATFORMS" $BUILD_ARGS
    docker buildx rm "$DOCKER_BUILDER" 2>/dev/null || echo "Builder ${DOCKER_BUILDER} not found or already removed, skipping."
fi
