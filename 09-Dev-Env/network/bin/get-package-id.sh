#!/bin/bash
if [ "$FABRIC_CFG_PATH" == "" ]; then 
   echo "This script requires the Environment to be setup!!! Use one of the following:"
   echo "> source  set-env.sh  acme"
   echo "> source  set-env.sh  budget"
   exit
fi
# Gets the package ID for the installed chaincode
# Usage: get-package-id.sh     -n [chaincode name default=$CC_NAME] -v [chaincode version default=$CC_VERSION] -h -e [Echo]
DIR="$( which set-chain-env.sh)"
DIR="$(dirname $DIR)"

# Read the current setup
source   $DIR/cc.env.sh

if [ "$ECHO_INFO" == "" ]; then
    ECHO_INFO="false"
fi

# utility function to extract the hash value from package-id
function extract_hash {
    data=$(echo "$CC2_PACKAGE_ID" | tr -t ':' ' ')
    set -- $data
    CC2_PACKAGE_ID_HASH=$2
}

HASH_ONLY="false"
while getopts "v:n:ohe" OPTION; do

    case $OPTION in

    v)
       CC_VERSION=${OPTARG}
       ;;
    n)
        CC_NAME=${OPTARG}
        ;;
    h)
        echo 'Usage: get-package-id.sh     -n [chaincode name default=$CC_NAME] -v [chaincode version default=$CC_VERSION] '
        echo "                             -h [displays the help]  -o [Just sets the Hash Code] -e [Do not echo]"
        exit
        ;;
    
    e)
      
      ECHO_INFO="true"
      ;;
    esac
done

# echo "--->$CC_NAME.$CC_VERSION"

# JQ Expression for extracting the 
# https://github.com/stedolan/jq/issues/370
# .installed_chaincodes[]  | select(.label=="gocc.1") | .package_id

# JQ_EXPRESSION='.installed_chaincodes[]  | select(.label=="gocc.1") | .package_id'
JQ_EXPRESSION='.installed_chaincodes[]  | select(.label=="'"$CC_NAME.$CC_VERSION"'") | .package_id'
OUTPUT=$(peer lifecycle chaincode queryinstalled -O json)

echo $JQ_EXPRESSION
echo $OUTPUT

if [ "$OUTPUT" == "{}" ]; then
    # echo "Package '$CC_NAME.$CC_VERSION' NOT found!!"
    export CC2_PACKAGE_ID=""
else
    export CC2_PACKAGE_ID=$(echo "$OUTPUT" | jq -r "$JQ_EXPRESSION")
    extract_hash
fi


# if [ "$HASH_ONLY" == "true" ]; then
#    extract_hash
# fi

if [ "$ECHO_INFO" == "true" ]; then
    echo "CC2_PACKAGE_ID=$CC2_PACKAGE_ID"
    echo "CC2_PACKAGE_ID_HASH=$CC2_PACKAGE_ID_HASH"
fi

# Write to the environment file
rm $CC2_ENV_FOLDER/get-package-id &> /dev/null

echo "# Generated: $(date)"   > $CC2_ENV_FOLDER/get-package-id
echo "CC2_PACKAGE_ID=$CC2_PACKAGE_ID" >>  $CC2_ENV_FOLDER/get-package-id
echo "CC2_PACKAGE_ID_HASH=$CC2_PACKAGE_ID_HASH" >>  $CC2_ENV_FOLDER/get-package-id