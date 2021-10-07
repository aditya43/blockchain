#######################
## reset the network ##
#######################

# move to the docker folder
cd ~/mount/network/docker

# shut down the containers from the compose file
docker-compose -f docker-compose-test-net.yaml down

# clear the volumes
docker volume prune

######################################
## start the network with a channel ##
######################################

# bring up the network
./network.sh up

# create the channel
./network.sh createChannel

#######################
## install chaincode ##
#######################

# go to the chaincode location
cd ~/mount/chaincode/fabcar/go

# add the dependencies
go mod vendor

# return to the network folder
cd ~/mount/network

# set cfg path
export FABRIC_CFG_PATH=$PWD/../config

# package the chaincode
peer lifecycle chaincode package fabcar.tar.gz --path ../chaincode/fabcar/go --lang golang --label fabcar_1

# Set environment to Org1
export CORE_PEER_TLS_ENABLED=true &&
export CORE_PEER_LOCALMSPID="Org1MSP" &&
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt &&
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp &&
export CORE_PEER_ADDRESS=localhost:7051

# Install the chaincode
peer lifecycle chaincode install fabcar.tar.gz

# Set environment to Org2
export CORE_PEER_LOCALMSPID="Org2MSP" &&
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt &&
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt &&
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp &&
export CORE_PEER_ADDRESS=localhost:9051

# Install the chaincode
peer lifecycle chaincode install fabcar.tar.gz

#######################
## approve chaincode ##
#######################

# Get the package ID of our chaincode
peer lifecycle chaincode queryinstalled

# export the ID as a variable
export CC_PACKAGE_ID=<...replace with ID...>
# For e.g. export CC_PACKAGE_ID=fabcar_1:762e0fe3dbeee0f7b08fb6200adeb4a3a20f649a00f168c0b3c2257e53b6e506

# approve for Org2
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name fabcar --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# Check the approvals
peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name fabcar --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json

# Set environment to Org1
export CORE_PEER_LOCALMSPID="Org1MSP" &&
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp &&
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt &&
export CORE_PEER_ADDRESS=localhost:7051

# approve for Org1
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name fabcar --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# Check the approvals
peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name fabcar --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json

# Commit the approved chaincode for both of the organizations
peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name fabcar --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

# checkout all the chaincode defenitions on the channel
peer lifecycle chaincode querycommitted --channelID mychannel --name fabcar --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# initialize the chaincode
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n fabcar --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"function":"InitLedger","Args":[]}'

# query the chaincode
peer chaincode query -C mychannel -n fabcar -c '{"Args":["queryAllCars"]}'
