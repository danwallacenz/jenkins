#!/usr/bin/env bash


### 1. Create Docker Swarm cluster 

# docker-machine rm -f \
#   node1 node2 node3

# ./create-cluster.sh

# # Enter the cluster
# eval $(docker-machine env node1)
# docker node ls

CLUSTER_DNS=$(docker-machine ip node1)
CLUSTER_IP=$(docker-machine ip node1)


# ### 2. Add Registry
# docker stack deploy -c registry.yml registry


# ### 3. Add Docker Flow Proxy 
eval $(docker-machine env node1)
docker network create -d overlay proxy

docker pull localhost:5000/docker-flow-proxy
docker pull localhost:5000/docker-flow-swarm-listener

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

docker stack ps proxy


### 4. Create Jenkins Docker image 

#image/create-docker-image.sh

# Exit the cluster
# eval $(docker-machine env -u)
# DOCKER_HUB_USER=danwallacenz
# TAG=setup
# docker image build -t $DOCKER_HUB_USER/jenkins:$TAG .
# docker image push $DOCKER_HUB_USER/jenkins:$TAG

# # Re-enter the cluster
eval $(docker-machine env node1)


### 5. Deploy Jenkins

echo "admin" | docker secret create jenkins-user -
echo "admin" | docker secret create jenkins-pass -

docker secret ls

export TAG=
# export REGISTRY=danwallacenz
export REGISTRY=localhost:5000

# Map /var/jenkins_home in every container to docker/jenkins
mkdir -p  docker/jenkins

docker pull localhost:5000/myjenkins

docker stack deploy -c jenkins.yml jenkins
while true; do
    REPLICAS=$(docker service ls | grep jenkins_main | awk '{print $4}')
    if [[ $REPLICAS == "1/1" ]]; then
        break
    else
        echo "Waiting for the Jenkins service..."
        sleep 10
    fi
done

docker stack ps myjenkins

echo ''
echo 'Wait until the Jenkins is running'
echo '$ eval $(docker-machine env node1)'
echo 'repeat... $ docker stack ps jenkins'

open "http://$CLUSTER_DNS/jenkins"

# open "http://$(docker-machine ip node1)/jenkins"

# open "http://$CLUSTER_DNS/jenkins/exit"


