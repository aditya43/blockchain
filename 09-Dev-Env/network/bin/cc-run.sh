#!/bin/bash
#Executes the chaincode in dev mode testing


DIR="$( which $BASH_SOURCE)"
DIR="$(dirname $DIR)"

source $DIR/to_absolute_path.sh
source $DIR/cc.env.sh

echo "GOPATH=$GOPATH  Name=$CC_NAME"
# Executes chaincode in dev mode

# To use this script launch the dev env in dev mode
source dev-mode.sh
if [ "$PEER_MODE" == "net" ]; then
    echo "=====>Can't run chaincode in terminal in 'net' mode!!!"
    echo "=====>Please use 'dev-init.sh  -d'  to launch the env in DEV mode."

    exit 1
fi


echo "+++Building the GoLang chaincode"
#go build -o $CC_PATH
# export GOCACHE=off

eval 'export CORE_CHAINCODE_ID_NAME=$CC_NAME:$CC_VERSION'

if [ "$ORGANIZATION_CONTEXT" == "acme" ] ; then
    eval 'export CORE_PEER_ADDRESS=localhost:7052'
elif [ "$ORGANIZATION_CONTEXT" == "budget" ] ; then
    eval 'export CORE_PEER_ADDRESS=localhost:8052'
else
    echo "Unknown Organization Context = $ORGANIZATION_CONTEXT....Aborting!!!"
    exit 0
fi

# https://github.com/hyperledger/fabric-samples/tree/master/chaincode-docker-devmode
# 2.0 needs this
eval 'export CORE_PEER_TLS_ENABLED=false'

# 2.0 needs the -peer.address
# go run  $GOPATH/src/$CC_PATH/*.go
go run  $GOPATH/src/$CC_PATH/*.go -peer.address $CORE_PEER_ADDRESS

echo "+ Launching the chaincode"

