#!/usr/bin/env bash

docker stack deploy -c viz.yml visualizer

while true; do
    VISUALIZER_REPLICA=$(docker service ls | grep visualizer_viz | awk '{print $4}')
    VISUALIZER_REPLICA=$(docker service ls | grep proxy_swarm-listener | awk '{print $4}')
    if [[ $VISUALIZER_REPLICA == "1/1" ]]; then
        break
    else
        echo "Waiting for the Visualizer service..."
        sleep 10
    fi
done

open "http://$(docker-machine ip node1):8081"