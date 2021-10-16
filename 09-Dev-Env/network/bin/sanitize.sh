#!/bin/bash

go clean -cache
echo    "==============Cleaning up the Dev containers & images ======"
docker rm $(docker ps -a -q)            &> /dev/null
docker rmi $(docker images dev-* -q)    &> /dev/null
dev_images=$(docker images --format '{{.Repository}}:{{.Tag}}' | grep dev-)
if [ "$dev_images" != "" ]; then
    docker rmi $(docker images --format '{{.Repository}}:{{.Tag}}' | grep dev-)
fi

sleep 3s

# Delete the volumes
export COMPOSE_PROJECT_NAME=acloudfan

docker volume prune -f

unset  FABRIC_CFG_PATH
unset  FABRIC_LOGGING_SPEC

unset CORE_PEER_ID
unset CORE_PEER_ADDRESS
unset CORE_PEER_LISTENADDRESS
unset CORE_PEER_LISTENADDRESS
unset CORE_PEER_CHAINCODELISTENADDRESS
unset CORE_PEER_GOSSIP_EXTERNALENDPOINT
unset CORE_PEER_LOCALMSPID
unset CORE_PEER_MSPCONFIGPATH
unset CORE_PEER_TLS_ENABLED
unset CORE_PEER_GOSSIP_USELEADERELECTION
unset CORE_PEER_GOSSIP_ORGLEADER
unset CORE_PEER_PROFILE_ENABLED
unset CORE_PEER_FILESYSTEMPATH
unset CORE_PEER_ADDRESS_CHAINCODELISTENADDRESS
unset CORE_PEER_ADDRESS_CHAINCODEADDRESS

unset FABRIC_CA_SERVER_HOME
unset FABRIC_CA_CLIENT_HOME


# Kill all running processes
killall   peer  &> /dev/null
killall   orderer &> /dev/null
killall   fabric-ca-server

# Kill all running containers and then clean up
docker  kill $(docker ps -q)        &> /dev/null
docker  rm   $(docker ps -a -q)     &> /dev/null

# Remove all of the ledgers from the file system
rm -rf $HOME/ledgers &> /dev/null

# Unset the environment variables
unset FABRIC_CFG_PATH
unset FABRIC_LOGGING_SPEC
unset CORE_PEER_MSPCONFIGPATH
unset CORE_PEER_LOCALMSPID
unset CORE_PEER_ADDRESS
unset ORDERER_ADDRESS


echo "Done. Clean like a whistle!!"


