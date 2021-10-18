#!/bin/bash
# Checks if the dev environment is running in dev mode
DIR="$(which $BASH_SOURCE)"
DIR="$(dirname $DIR)"

TEST=$(cat "$DIR/_launch.sh" | grep PEER_MODE=dev)

# echo $TEST

if [ "$TEST" = "#PEER_MODE=dev" ]; then 
    export PEER_MODE=dev
else
    export PEER_MODE=net
fi

export PEER_MODE

echo "Peer Launch Mode=$PEER_MODE"
