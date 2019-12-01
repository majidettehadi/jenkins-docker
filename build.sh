#!/usr/bin/env bash

# Read arg from build.properties

set -x
. build.properties
docker build --force-rm \
    --build-arg JENKINS_VERSION=$JENKINS_VERSION \
    -t $REPO_NAME:latest \
    -t $REPO_NAME:$JENKINS_VERSION .
