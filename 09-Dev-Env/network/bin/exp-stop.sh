#!/bin/bash

# Launch the explorer 
function usage {
    echo "Usage:  ./exp-start.sh "
    echo "Launches the Explorer."
    echo "Fails if explorer is already up!!!"
}

DIR="$( which $BASH_SOURCE)"
DIR="$(dirname $DIR)"

cd $DIR/../devenv

echo "===>Stopping explorer....please wait"
docker-compose -f ./compose/docker-compose.explorer.yaml down 2> /dev/null
echo "Done."
