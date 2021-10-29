#!/bin/bash
# This launches the event listener
# Currently setup to support only cryptogen
# REQUIRES Node JS to be installed
# Updated for Fabric 2.0 : April 2020

DIR="$( which $BASH_SOURCE)"
DIR="$(dirname $DIR)"
BINS_FOLDER=$DIR

source cc.env.sh

function usage {
    echo "event.sh   -t [EVENT_TYPE = chaincode (default)  |  block | txn]"
    echo "           -n [CC_NAME = Default picked from chain environment]"
    echo "           -e EVENT_NAME = Must provide name of the event"
    echo "           -c CHANNEL_ID = Channel ID default=airlinechannel"
    echo "           -C CRYPTO_TYPE = cryptogen | fabric-ca"
}

if [ -z $EVENT_PATH ]; then
    EVENT_PATH=$HOME/HLFChaincode_Utils
    echo "Using EVENT_PATH=$EVENT_PATH"
fi

while getopts "t:n:e:c:h" OPTION; do
    case $OPTION in
    t)
        LISTENER_TYPE=${OPTARG}
        ;;
    n)
        CHAINCODE_NAME=${OPTARG}
        ;;
    e)
        EVENT_NAME=${OPTARG}
        ;;
    c)
        CHANNEL_ID=${OPTARG}
        ;;
    C)
        CRYPTO_TYPE=${OPTARG}
        ;;
    *)
        usage
        exit
        ;;

    esac
done

# Validate and set to defaults

# If listener type not specified then set to chaincode
if [ -z $LISTENER_TYPE ]; then
    LISTENER_TYPE=chaincode
fi
# If name not specified then it is picked up from the chain env
if [ -z $CHAINCODE_NAME ]; then 
    CHAINCODE_NAME=$CC_NAME
fi
# Event name is mandatory if the listener type is chaincode
if [ -z $EVENT_NAME ]; then
    if [ $LISTENER_TYPE="chaincode" ]; then
        # EVENT_NAME=TokenValueChanged
        echo "For listener type = chaincode, Event name must be provided!!!"
        exit 0
    fi
fi
# Default crypto type is cryptogen
if [ -z $CRYPTO_TYPE ]; then
    CRYPTO_TYPE=cryptogen
fi
# If channel ID not specified then it is picked from chaincode env
if [ -z $CHANNEL_ID ]; then
    CHANNEL_ID=$CC_CHANNEL_ID
fi
CRYPTO_FOLDER="$BINS_FOLDER/../crypto/crypto-config/peerOrganizations"


cd $EVENT_PATH
node  --no-warnings events.js  "$LISTENER_TYPE" "$CHAINCODE_NAME" "$EVENT_NAME" "$CHANNEL_ID" "$CRYPTO_TYPE"  "$CRYPTO_FOLDER" 