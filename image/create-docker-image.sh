#!/usr/bin/env bash

eval $(docker-machine env -u)

DOCKER_HUB_USER=danwallacenz
TAG=setup


## Build the image - see Dockerfile
docker image build -t $DOCKER_HUB_USER/jenkins:$TAG .


## Push to Docker Hub
docker image push $DOCKER_HUB_USER/jenkins:$TAG