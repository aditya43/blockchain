#!/bin/bash

# The DB Regeneration takes a long time 
# On some machines this time may need to be adjusted
# If you can't reach explorer alternative is to use exp-init.sh
SLEEP_TIME=15s

# Launch the explorer 
function usage {
    echo "Usage:  ./exp-start.sh "
    echo "Launches the Explorer."
    echo "Fails if explorer is already up!!!"
}

DIR="$( which $BASH_SOURCE)"
DIR="$(dirname $DIR)"

cd $DIR/../devenv

echo "====>Launching explorer....please wait"

docker-compose -f ./compose/docker-compose.explorer.yaml up -d 2> /dev/null

# This is to give time to containers to launch - insufficient time will
# lead to failure of initialization. If that happens either increas time
# or just execute exp-init.sh
sleep   $SLEEP_TIME

exp-init.sh

# exp-logs.sh  console

echo "===Explorer logs Use: exp-logs.sh   console ==="
echo "Done   http://localhost:8080"