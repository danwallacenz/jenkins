#!/usr/bin/env bash

# pre-requisites - create cluster (./create-cluster.sh)

# eval $(docker-machine env -u)
eval $(docker-machine env node1)

docker pull registry:2.5.0

docker pull jenkins:2.60.2-alpine
docker tag jenkins:2.60.2-alpine localhost:5000/jenkins:latest

docker pull vfarcic/docker-flow-swarm-listener:17.07.28-1
docker tag vfarcic/docker-flow-swarm-listener:17.07.28-1 localhost:5000/docker-flow-swarm-listener:latest

docker pull vfarcic/docker-flow-proxy:17.08.18-26
docker tag vfarcic/docker-flow-proxy:17.08.18-26 localhost:5000/docker-flow-proxy:latest

docker pull dockersamples/visualizer:stable
docker tag dockersamples/visualizer:stable localhost:5000/visualizer:latest


docker image ls -f=reference='localhost:5000/*:*'


REGISTRY_UP=false


docker stack deploy -c registry.yml registry
while true; do
    REPLICAS=$(docker service ls | grep registry_main | awk '{print $4}')
    if [[ $REPLICAS == "1/1" ]]; then
        REGISTRY_UP=true
        break
    else
        echo "Waiting for the Registry service..."
        sleep 2
    fi
done

curl $(docker-machine ip node1):5000/v2/_catalog


if $REGISTRY_UP; then
    # docker tag jenkins:2.60.2-alpine localhost:5000/jenkins:${TAG:-2.60.2-alpine}
    docker push localhost:5000/jenkins:latest

    # docker tag vfarcic/docker-flow-swarm-listener:17.07.28-1 localhost:5000/docker-flow-swarm-listener:${TAG:-17.07.28}
    docker push localhost:5000/docker-flow-swarm-listener:latest

    # docker tag vfarcic/docker-flow-proxy:17.08.18-26 localhost:5000/docker-flow-proxy:${TAG:-17.08.18-26}
    docker push localhost:5000/docker-flow-proxy:latest

    # docker tag dockersamples/visualizer:stable localhost:5000/visualizer:${TAG:-stable}
    docker push localhost:5000/visualizer:latest

    curl $(docker-machine ip node1):5000/v2/_catalog
else
    echo "Problem - Registry is down!"
fi

