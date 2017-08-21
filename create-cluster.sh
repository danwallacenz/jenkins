#!/usr/bin/env bash

if [[ "$(uname -s )" == "Linux" ]]; then
  export VIRTUALBOX_SHARE_FOLDER="$PWD:$PWD"
fi

for i in 1 2 3; do
    docker-machine create \
        -d virtualbox \
        node$i
done

eval $(docker-machine env node1)

docker swarm init \
  --advertise-addr $(docker-machine ip node1)

TOKEN=$(docker swarm join-token -q manager)

for i in 2 3; do
    eval $(docker-machine env node$i)

    docker swarm join \
        --token $TOKEN \
        --advertise-addr $(docker-machine ip node$i) \
        $(docker-machine ip node1):2377
done

for i in 1 2 3; do
    eval $(docker-machine env node$i)

    docker node update \
        --label-add env=jenkins-master \
        node$i
done

eval $(docker-machine env node1)

echo ">> The swarm cluster is up and running"