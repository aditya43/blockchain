#!/bin/bash
# Gets the installed chaincodes from the peer
if [ "$FABRIC_CFG_PATH" == "" ]; then 
   echo "This script requires the Environment to be setup!!! Use one of the following:"
   echo "> source  set-env.sh  acme"
   echo "> source  set-env.sh  budget"
   exit
fi

DIR="$( which set-chain-env.sh)"
DIR="$(dirname $DIR)"
# echo $DIR
source $DIR/to_absolute_path.sh
# Read the current setup
source   $DIR/cc.env.sh

function usage {
    echo   "Usage:  get-cc-installed.sh -n [chaincode_name Default='\$CC_NAME'] -e [Echo] -h [help]"
    echo   "Gets the information on installed chaincode and writes out to the environment variables"
    echo   "Environment variables set by this script:"
    echo   "INSTALLED_COUNT=Total number of chaincode installed"
    echo   "INSTALLED_CC_VERSIONS=Number of installed versions for specified chaincode"
    echo   "INSTALLED_MAX_LABEL=Label for latest version"
    echo   "INSTALLED_MAX_LABEL_VERSION=Latest version of specified chaincode"
    echo   "INSTALLED_CHAINCODE_LABELS=All chaincode labels installed on the peer"
}

# Write to the environment file
function write_out {
    echo "# Generated: $(date)"   > $CC2_ENV_FOLDER/get-cc-installed
    echo "# CC_NAME = $CC_NAME" >> $CC2_ENV_FOLDER/get-cc-installed
    echo "INSTALLED_COUNT=$INSTALLED_COUNT"             >> $CC2_ENV_FOLDER/get-cc-installed
    echo "INSTALLED_CC_VERSIONS=$INSTALLED_CC_VERSIONS"       >> $CC2_ENV_FOLDER/get-cc-installed
    echo "INSTALLED_MAX_LABEL=$INSTALLED_MAX_LABEL"             >> $CC2_ENV_FOLDER/get-cc-installed
    echo "INSTALLED_MAX_LABEL_VERSION=$INSTALLED_MAX_LABEL_VERSION"       >> $CC2_ENV_FOLDER/get-cc-installed
    echo "INSTALLED_CHAINCODE_LABELS=$INSTALLED_CHAINCODE_LABELS" >> $CC2_ENV_FOLDER/get-cc-installed
    echo "INSTALLED_MAX_PACKAGE_ID=$INSTALLED_MAX_PACKAGE_ID" >> $CC2_ENV_FOLDER/get-cc-installed
    echo "INSTALLED_MAX_LABEL_INTERNAL_VERSION=$INSTALLED_MAX_LABEL_INTERNAL_VERSION" >> $CC2_ENV_FOLDER/get-cc-installed
}


ECHO_INFO="false"
while getopts "n:he" OPTION; do
    case $OPTION in
    h)
        usage
        exit
        ;;
    e)
        ECHO_INFO="true"
        ;;
    n)
        CC_NAME=${OPTARG}
    esac
done

OUTPUT=$(peer lifecycle chaincode queryinstalled -O json)
JQ_EXPRESSION='.installed_chaincodes | length'
INSTALLED_COUNT=$(echo $OUTPUT | jq -r "$JQ_EXPRESSION") 

INSTALLED_MAX_LABEL_VERSION=-1
INSTALLED_MAX_LABEL_INTERNAL_VERSION=-1
INSTALLED_CC_VERSIONS=0
INSTALLED_CHAINCODE_LABELS=""
for (( c=0; c<$INSTALLED_COUNT; c++ ))
do
    # Extract Label
    JQ_EXPRESSION=".installed_chaincodes[$c].label"
    LABEL=$(echo $OUTPUT | jq -r "$JQ_EXPRESSION")
    INSTALLED_CHAINCODE_LABELS="$INSTALLED_CHAINCODE_LABELS $LABEL,"

    #Extract Package ID
    JQ_EXPRESSION=".installed_chaincodes[$c].package_id"
    PACKAGE_ID=$(echo $OUTPUT | jq -r "$JQ_EXPRESSION")
    # echo $PACKAGE_ID

    # Check if label starts with CC_NAME
    if [[ "$LABEL" == "$CC_NAME."* ]]; then
        INSTALLED_CC_VERSIONS=$((INSTALLED_CC_VERSIONS+1))
        # Replace the '$CC_NAME.'
        VERSIONS=$(echo $LABEL |   tr -d "$CC_NAME.0")
        # echo $LABEL
        # Replace - with ,  so we can split into array
        # STR=$(echo $VERSIONS | tr '-' ', ')
        IFS='-' read -a ARR <<< $VERSIONS
        VERSION="${ARR[0]}"
        INTERNAL_VERSION="${ARR[1]}"
        # echo "IN=$INTERNAL_VERSION  $VERSION    $VERSIONS"
        # echo "Found version of $CC_NAME $VERSION"

        # check max version
        if ((VERSION > INSTALLED_MAX_LABEL_VERSION)); then
            INSTALLED_MAX_LABEL_VERSION=$VERSION
            # INSTALLED_MAX_LABEL=$LABEL
            # INSTALLED_MAX_PACKAGE_ID=$PACKAGE_ID
        fi

        # check max installed internal version
        if ((INTERNAL_VERSION > INSTALLED_MAX_LABEL_INTERNAL_VERSION)); then
            INSTALLED_MAX_LABEL_INTERNAL_VERSION=$INTERNAL_VERSION
            INSTALLED_MAX_LABEL=$LABEL
            INSTALLED_MAX_PACKAGE_ID=$PACKAGE_ID
        fi
    fi
done

write_out

if [ "$ECHO_INFO" == "true" ]; then
   cat $CC2_ENV_FOLDER/get-cc-installed
fi
