README.md

*Create a Failure-proof Jenkins on MacOS

*** Prerequisites
    * Docker for Mac
    * VirtualBox
    * Git

*** Create a Cluster of Machines
First, we'll create a cluster of three VMs with Docker Machine installed on each. 
In Docker Swarm terms, they'll all be "manager" nodes.

```bash
scripts/create-cluster.sh

eval $(docker-machine env node1)

docker node ls
```

*** Download and Register the Docker Images We'll Need

This step will download network utility images (docker-flow-swarm-listener & docker-flow-proxy - see url), a local registry to save downloading too often, a Docker Swarm visualizer tool, and a base Jenkins image - which we'll build upon.

```bash
scripts/download-tag-push-images.sh

curl $(docker-machine ip node1):5000/v2/_catalog
```

*** Create an Enhanced Jenkins Docker Image
```bash
scripts/buid-push-myjenkins-image.sh

curl $(docker-machine ip node1):5000/v2/_catalog 
```