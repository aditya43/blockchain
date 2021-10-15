#!/bin/bash
#Launches the environment with the fabric-ca generated crypto
#Environment is NOT compatible with chain commands
DIR="$( which $BASH_SOURCE)"
DIR="$(dirname $DIR)"

source $DIR/to_absolute_path.sh

to-absolute-path $DIR
DIR=$ABS_PATH

cd $DIR/../caserver
docker-compose up -d
