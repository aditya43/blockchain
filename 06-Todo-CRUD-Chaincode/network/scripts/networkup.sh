#!/bin/bash

pushd ~/mount/network/docker

docker-compose -f ./docker-compose-test-net.yaml up -d 

popd