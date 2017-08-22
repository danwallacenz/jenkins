#!/usr/bin/env bash

eval $(docker-machine env    node1)

# DOCKER_HUB_USER=danwallacenz
REGISTRY=localhost:5000
TAG=


## Build the image - see Dockerfile
docker image build -t $REGISTRY/myjenkins:${TAG:-latest} .

## Push to registry
docker image push $REGISTRY/myjenkins:${TAG:-latest}

curl $(docker-machine ip node1):5000/v2/_catalog