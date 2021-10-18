#!/bin/bash
# Checks the status of the dev environment containers
DOCKER_CONTAINERS=$(docker ps -q)

if [ "$DOCKER_CONTAINERS" == '' ]; then
    DOCKER_CONTAINERS_STATUS='down'
    echo "Docker containers are '$DOCKER_CONTAINERS_STATUS'"
else
    DOCKER_CONTAINERS_STATUS='up'
    source dev-mode.sh &> /dev/null
    echo "Docker containers are '$DOCKER_CONTAINERS_STATUS' in Mode='$PEER_MODE'"
fi

export DOCKER_CONTAINERS_STATUS


