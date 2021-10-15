#!/bin/bash

# Provides easy access to the chaincode container logs

usage() {
    echo "cc-logs.sh   [-o ORG_NAME default=acme]  [-p PEER_NAME default=acme-peer1] [-f   Follow] [-t  Number]"
    echo "              Shows the logs for the chaincode container. "
    echo "              -f follows the logs, useful when debugging in net mode "
    echo "              -t flag is equivalent to --tail flag for docker logs"
    echo "              -h  shows the usage"
}

CONTAINER_PREFIX=dev
ORG_NAME=$ORGANIZATION_CONTEXT
PEER_NAME="$ORGANIZATION_CONTEXT-peer1"
source cc.env.sh
LOG_OPTIONS=""
while getopts "o:p:t:fh" OPTION; do
    case $OPTION in
    o)
        ORG_NAME=${OPTARG}
        ;;
    p)
        PEER_NAME=${OPTARG}
        ;;
    f)
        LOG_OPTIONS="$LOG_OPTIONS -f"
        ;;
    t)
        LOG_OPTIONS="$LOG_OPTIONS --tail ${OPTARG}"
        ;;
    h)
        usage
        exit 1
        ;;
    *)
        echo "Incorrect options provided"
        exit 1
        ;;
    esac
done

# 2.0 
# Get the package ID
# get-package-id.sh
# source $CC2_ENV_FOLDER/get-package-id
get-cc-installed.sh
source $CC2_ENV_FOLDER/get-cc-installed &> /dev/null

# CC_CONTAINER_NAME=$INSTALLED_MAX_PACKAGE_ID
INSTALLED_MAX_PACKAGE_ID=$(echo $INSTALLED_MAX_PACKAGE_ID | tr ':' '-' )
CC_CONTAINER_NAME="$CONTAINER_PREFIX-$PEER_NAME.$ORG_NAME.com-$INSTALLED_MAX_PACKAGE_ID"
echo $CC_CONTAINER_NAME

#CC_CONTAINER_NAME="$CONTAINER_PREFIX-$PEER_NAME.$ORG_NAME.com-$CC_NAME.$CC_VERSION-$CC2_PACKAGE_ID_HASH"

# cmd="docker logs $LOG_OPTIONS $CC_CONTAINER_NAME"

cmd="docker logs $LOG_OPTIONS $CC_CONTAINER_NAME"

echo "Command: $cmd"

docker logs $LOG_OPTIONS $CC_CONTAINER_NAME 

