#!/usr/bin/env bash

eval $(docker-machine ip node1)

# DOCKER_HUB_USER=danwallacenz
REGISTRY=localhost:5000
TAG=


## Build the image - see Dockerfile
# docker image build -t $DOCKER_HUB_USER/jenkins:${TAG:-latest} .
docker image build -t $REGISTRY/myjenkins:${TAG:-latest} .

## Push to Docker Hub
docker image push $REGISTRY/myjenkins:${TAG:-latest}

# docker tag $DOCKER_HUB_USER/jenkins:${TAG:-latest} localhost:5000/jenkins:${TAG:-latest}

# docker push localhost:5000/jenkins:${TAG:-latest}

# curl $(docker-machine ip node1):5000/v2/_catalog