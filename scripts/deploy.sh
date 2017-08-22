#!/usr/bin/env bash


### 1. Create Docker Swarm cluster 

# docker-machine rm -f \
#   node1 node2 node3

# ./create-cluster.sh

docker node ls

CLUSTER_DNS=$(docker-machine ip node1)

# Attach to a DM in the cluster
eval $(docker-machine env node1)


# ### 1. Deploy Registry
# docker stack deploy -c ../registry.yml registry


### 2. Deploy Docker Flow Proxy & Swarm Listener
docker stack deploy -c docker-flow-proxy.yml proxy

while true; do
    PROXY_REPLICAS=$(docker service ls | grep proxy_proxy | awk '{print $4}')
    SWARM_LISTENER_REPLICAS=$(docker service ls | grep proxy_swarm-listener | awk '{print $4}')
    if [[ $PROXY_REPLICAS == "3/3" && $SWARM_LISTENER_REPLICAS == "1/1" ]]; then
        break
    else
        echo "Waiting for the Proxy service..."
        sleep 10
    fi
done



### 5. Deploy Jenkins

echo "admin" | docker secret create jenkins-user -
echo "admin" | docker secret create jenkins-pass -

docker secret ls

export TAG=
# export REGISTRY=danwallacenz
export REGISTRY=localhost:5000

# Map /var/jenkins_home in every container to docker/jenkins
mkdir -p  docker/jenkins


docker stack deploy -c jenkins.yml jenkins

while true; do
    REPLICAS=$(docker service ls | grep jenkins_main | awk '{print $4}')
    if [[ $REPLICAS == "1/1" ]]; then
        break
    else
        echo "Waiting for the Jenkins service..."
        sleep 5
    fi
done


### Open Jenkins console
open "http://$(docker-machine ip node1)/jenkins"


# open "http://$CLUSTER_DNS/jenkins/exit"


