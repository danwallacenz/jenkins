#!/usr/bin/env bash

eval $(docker-machine env node1)

#scripts/download-tag-push-images.sh


#scripts/build-push-myjenkins-image.sh


scripts/deploy.sh

