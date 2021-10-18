#!/bin/bash

# Launches the test environment
function usage {
    echo "Usage:  ./dev-start.sh "
    echo "Launches the devenv."
}

DIR="$( which $BASH_SOURCE)"
DIR="$(dirname $DIR)"

cd $DIR/../devenv

# Start it up
source _launch.sh

# Sleep for 5s
sleep 5s

# Start up the explorer
# exp-init.sh

# 
source dev-mode.sh
echo  "Done. Started the dev environment in Mode=$PEER_MODE."

