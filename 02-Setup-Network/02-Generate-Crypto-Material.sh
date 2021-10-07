#######################
## reset the network ##
#######################
# move to the docker folder
cd ~/mount/network/docker

# shut down the containers from the compose file
docker-compose -f docker-compose-test-net.yaml down

# clear the volumes
docker volume prune

#############################
## create crypto materials ##
#############################
# remove the old materials
sudo rm -fr ~/mount/network/organizations/ordererOrganizations/* &&
sudo rm -fr ~/mount/network/organizations/peerOrganizations/* &&
sudo rm -fr ~/mount/network/system-genesis-block/*

# move to network
cd ..

# generate crypto materials
cryptogen generate --config=./organizations/cryptogen/crypto-config-org1.yaml --output="organizations"
cryptogen generate --config=./organizations/cryptogen/crypto-config-org2.yaml --output="organizations"
cryptogen generate --config=./organizations/cryptogen/crypto-config-orderer.yaml --output="organizations"

# set the cfg path
export FABRIC_CFG_PATH=$PWD/configtx/

# create the genesis block
configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock ./system-genesis-block/genesis.block
