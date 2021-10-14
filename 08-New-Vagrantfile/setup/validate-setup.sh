#!/bin/bash
# Validate all of the setup in one shot

echo "********  Validate: Docker ******** "
docker version
docker-compose version

read -p "Press enter to continue...."

echo "********  Validate: Go ******** "
go version
type govendor

read -p "Press enter to continue...."

echo "********  Validate: Fabric ******** "
peer version 
orderer version

read -p "Press enter to continue...."

echo "********  Validate: Fabric CA ******** "
fabric-ca-client version
fabric-ca-server version

read -p "Press enter to continue...."
