#!/bin/bash

# Shuts down the enviornment

DIR="$( which $BASH_SOURCE)"
DIR="$(dirname $DIR)"

cd $DIR/../devenv

source _shutdown.sh

echo "Done. To Re-launch use: dev-start.sh"