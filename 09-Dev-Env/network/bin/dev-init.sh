#!/bin/bash

DIR="$( which $BASH_SOURCE)"
DIR="$(dirname $DIR)"

source $DIR/to_absolute_path.sh

to-absolute-path $DIR
DIR=$ABS_PATH

# 2.0 source the CC vars so we can cleanup the packages
set-chain-env.sh -z
source   $DIR/cc.env.sh
rm -rf $CC2_PACKAGE_FOLDER &> /dev/null

# Time to sleep for containers to launch
COUCHDB_SLEEP_TIME=5s

function usage {
    echo    "dev-init.sh -opt -opt ...    Initializes the dev setup"
    echo    "Options:   -h Help  -d Dev mode -s CouchDB  -e  Setup explorer -c CLI container"
    echo    "To start the dev environment:  dev-start.sh"
    echo    "To stop the dev environment:   dev-stop.sh"
}

# Give time to containers for starting up
SLEEP_TIME=5s
# DB containers need more time
# Adjust this if the validation is failing when launched with Couch DB
SLEEP_TIME_DB=10s

###### Generate the Launch & Shytdown scripts based on options ###########
# Pending t=TLS enable     k=Kafka enable   c=cli
    PEER_MODE=net
    LAUNCH_SCRIPT="docker-compose  -f ./compose/docker-compose.base.yaml "
    LAUNCH_DEV_MODE=""
    LAUNCH_SCRIPT_DB=""
    LAUNCH_SCRIPT_EXPLORER=""
    LAUNCH_SCRIPT_CLI=""
    while getopts "dcehs" OPTION; do
        case $OPTION in
        h)  usage
            exit
            ;;
        d) 
            LAUNCH_DEV_MODE=" -f ./compose/docker-compose.dev.yaml "
            PEER_MODE=dev
            ;;
        s)
            LAUNCH_SCRIPT_DB=" -f ./compose/docker-compose.couchdb.yaml "
            SLEEP_TIME=$SLEEP_TIME_DB
            ;;
        e)
            LAUNCH_SCRIPT_EXPLORER=" -f ./compose/docker-compose.explorer.yaml "
            ;;
        c)
            LAUNCH_SCRIPT_CLI=" -f ./compose/docker-compose.cli.yaml "
            ;;
        *)
            usage
            exit
        esac
    done
    LAUNCH_SCRIPT="$LAUNCH_SCRIPT  $LAUNCH_DEV_MODE $LAUNCH_SCRIPT_DB $LAUNCH_SCRIPT_EXPLORER $LAUNCH_SCRIPT_CLI "
    SHUTDOWN_SCRIPT="$LAUNCH_SCRIPT down "
    LAUNCH_SCRIPT="$LAUNCH_SCRIPT up -d"

    # Before overwriting shutdown - we need to shutdown the environment
    echo    "==============Stopping the Dev Environment ======"
    dev-stop.sh &> /dev/null

    echo "#PEER_MODE=$PEER_MODE" > $DIR/_launch.sh
    echo "#Command=dev-init.sh ${BASH_ARGV[*]} " >> $DIR/_launch.sh
    echo "#Generated: $(date) " >> $DIR/_launch.sh
    echo "$LAUNCH_SCRIPT --remove-orphans" >> $DIR/_launch.sh
    echo "#PEER_MODE=$PEER_MODE" > $DIR/_shutdown.sh
    echo "#Command=dev-init.sh ${BASH_ARGV[*]} " >> $DIR/_shutdown.sh
    echo "#Generated: $(date) " >> $DIR/_shutdown.sh
    echo "$SHUTDOWN_SCRIPT" >> $DIR/_shutdown.sh

    echo "Created the scripts...{ _launch.sh   _shutdown.sh }"
##################################################################################



# Remove all chaincode image containers
echo    "==============Cleaning up the Dev containers & images ======"

# REMOVE the dev- container images also - TBD
docker rm $(docker ps -a -q)            &> /dev/null
docker rmi $(docker images dev-* -q)    &> /dev/null

# Initializes the dev setup
rm -rf $DIR/../crypto/crypto-config  &> /dev/null
rm $DIR/../config/*.block &> /dev/null
rm $DIR/../config/*.tx &> /dev/null
sudo rm -rf $HOME/ledgers &> /dev/null


# Copy the aprorpriate compose file

if [ "$1" == "dev" ]; then
    PEER_MODE=dev
else
    PEER_MODE=net
fi
# cp "$DIR/../devenv/compose/docker-compose.$PEER_MODE.yaml"  "$DIR/../devenv/docker-compose.yaml"
# echo "Initializing & Starting environment in mode = $PEER_MODE"

# Generates the crypto material for the dev enviornment
echo    '================ Generating crypto ================'
CRYPTO_CONFIG_YAML=$DIR/../config/crypto-config.yaml
cryptogen generate --config=$CRYPTO_CONFIG_YAML --output=$DIR/../crypto/crypto-config

# Generates the orderer | generate genesis block for ordererchannel
# export ORDERER_GENERAL_LOGLEVEL=debug
export FABRIC_LOGGING_SPEC=INFO
export FABRIC_CFG_PATH=$DIR/../config

# Create the Genesis Block
echo    '================ Writing Genesis Block ================'
GENESIS_BLOCK=$DIR/../config/airline-genesis.block
ORDERER_CHANNEL_ID=ordererchannel
configtxgen -profile AirlineOrdererGenesis -outputBlock $GENESIS_BLOCK -channelID $ORDERER_CHANNEL_ID

echo    '================ Writing airlinechannel ================'
CHANNEL_ID=airlinechannel
CHANNEL_CREATE_TX=$DIR/../config/airline-channel.tx
configtxgen -profile AirlineChannel -outputCreateChannelTx $CHANNEL_CREATE_TX -channelID $CHANNEL_ID

echo    '================ Generate the anchor Peer updates ======'

ANCHOR_UPDATE_TX=$DIR/../config/airline-anchor-update-acme.tx
configtxgen -profile AirlineChannel -outputAnchorPeersUpdate $ANCHOR_UPDATE_TX -channelID $CHANNEL_ID -asOrg AcmeMSP

ANCHOR_UPDATE_TX=$DIR/../config/airline-anchor-update-budget.tx
configtxgen -profile AirlineChannel -outputAnchorPeersUpdate $ANCHOR_UPDATE_TX -channelID $CHANNEL_ID -asOrg BudgetMSP

echo    '================ Launch the network ================'
$DIR/dev-start.sh

# Couch DB takes time to start
if [ "$LAUNCH_SCRIPT_DB" != "" ]; then 
    echo "Giving time to CouchDB to Launch ... "
    sleep $COUCHDB_SLEEP_TIME
fi

export CORE_PEER_ID=init.sh
echo    '========= Submitting txn for channel creation as AcmeAdmin ============'
CRYPTO_CONFIG_ROOT_FOLDER=$DIR/../crypto/crypto-config/peerOrganizations
ORG_NAME=acme.com
CHANNEL_TX_FILE=$DIR/../config/airline-channel.tx
ORDERER_ADDRESS=localhost:7050
export CORE_PEER_LOCALMSPID=AcmeMSP
export CORE_PEER_MSPCONFIGPATH=$CRYPTO_CONFIG_ROOT_FOLDER/$ORG_NAME/users/Admin@acme.com/msp
peer channel create -o $ORDERER_ADDRESS -c airlinechannel -f $CHANNEL_TX_FILE


sleep $SLEEP_TIME

echo    '========= Joining the acme-peer1 to Airline channel ============'
AIRLINE_CHANNEL_BLOCK=./airlinechannel.block
export CORE_PEER_ADDRESS=acme-peer1.acme.com:7051
peer channel join -o $ORDERER_ADDRESS -b $AIRLINE_CHANNEL_BLOCK
# Update anchor peer on channel for acme
# sleep  3s
sleep $SLEEP_TIME
ANCHOR_UPDATE_TX=$DIR/../config/airline-anchor-update-acme.tx
peer channel update -o $ORDERER_ADDRESS -c airlinechannel -f $ANCHOR_UPDATE_TX

echo    '========= Joining the budget-peer1 to Airline channel ============'
# peer channel fetch config $AIRLINE_CHANNEL_BLOCK -o $ORDERER_ADDRESS -c airlinechannel
export CORE_PEER_LOCALMSPID=BudgetMSP
ORG_NAME=budget.com
export CORE_PEER_ADDRESS=budget-peer1.budget.com:8051
export CORE_PEER_MSPCONFIGPATH=$CRYPTO_CONFIG_ROOT_FOLDER/$ORG_NAME/users/Admin@budget.com/msp
peer channel join -o $ORDERER_ADDRESS -b $AIRLINE_CHANNEL_BLOCK
# Update anchor peer on channel for budget
sleep  $SLEEP_TIME
ANCHOR_UPDATE_TX=$DIR/../config/airline-anchor-update-budget.tx
peer channel update -o $ORDERER_ADDRESS -c airlinechannel -f $ANCHOR_UPDATE_TX

# Initialize the explorer only if -e option was used
if [ "$LAUNCH_SCRIPT_EXPLORER" != "" ]; then
    echo "=========  Initializing the Explorer ============"
    exp-init.sh
    echo  ""
    echo  "Done. To validate execute validate.sh & hit browser to http://localhost:8080"
fi

echo    '========= Anchor peer update tx for BudgetMSP ====='



echo    '========= Anchor peer update tx for AcmeMSP ====='
# export ORG_NAME=acme.com
# export CORE_PEER_LOCALMSPID=AcmeMSP
# export CORE_PEER_MSPCONFIGPATH=$CRYPTO_CONFIG_ROOT_FOLDER/$ORG_NAME/users/Admin@acme.com/msp



rm  $AIRLINE_CHANNEL_BLOCK

echo "=== Initialization completed * Environment launched ==="
echo "=== dev-stop.sh    to stop"
echo "=== dev-start.sh   to start"
echo "Done."