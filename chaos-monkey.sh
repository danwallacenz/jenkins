#!/usr/bin/env bash


### Jenkins failover

# Find the node Jenkins is running on
NODE=$(docker service ps \
    -f desired-state=running jenkins \
    | tail -n +2 | awk '{print $4}')

echo Jenkins is running on $NODE

# Switch to that node's DM
eval $(docker-machine env $NODE)

# Remove the Jenkins container
JENKINS_CONTAINER=$(docker ps -qa \
    -f label=com.docker.stack.namespace=jenkins \
    -f status=running)
echo Jenkins container = $JENKINS_CONTAINER

docker rm -f $JENKINS_CONTAINER


# docker rm -f $(docker ps -qa \
#     -f label=com.docker.swarm.service.name=jenkins \
#     -f status=running)


while true; do
    REPLICAS=$(docker service ls | grep jenkins_main | awk '{print $4}')
    if [[ $REPLICAS == "1/1" ]]; then
        break
    else
        echo "Waiting for the Jenkins service..."
        sleep 10
    fi
done

docker service ps jenkins

# JENKINS_CONTAINER=$(docker ps -qa \
#     -f label=com.docker.stack.namespace=jenkins \
#     -f status=running)
# echo $JENKINS_CONTAINER
# #echo $(docker ps -qa -f status=running)


# echo $(docker ps -qa \
#     -f label=com.docker.swarm.service.name=jenkins \
#     -f status=running)






