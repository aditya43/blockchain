#######################
## start the network ##
#######################

# move to the docker folder
cd ~/mount/network/docker

# start the containers from the compose file
docker-compose -f docker-compose-test-net.yaml up -d

# checkout the network
docker ps