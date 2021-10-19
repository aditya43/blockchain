# Removes the file cc.env.sh
# Since the Chaincode parameters are persisted in the file
# Sometimes it may lead to unintended impact. As a good practice
# Reset the chaincode environment before testing

# Updated for Fabric 2.0

DIR="$( which set-chain-env.sh)"
DIR="$(dirname $DIR)"

rm $DIR/cc.env.sh

unset CC_INVOKE_ARGS
unset CC_QUERY_ARGS
unset CC_PRIVATE_DATA_JSON
unset CC_PATH
unset CC_CHANNEL_ID
unset CC_LANGUAGE
unset CC_NAME
unset CC_ENDORSEMENT_POLICY
unset CC_CONSTRUCTOR
unset CC_VERSION

# Fabric v2.x variables
unset CC2_SEQUENCE
unset CC2_INIT_REQUIRED
unset CC2_PACKAGE_FOLDER
unset CC2_SIGNATURE_POLICY
unset CC2_CHANNEL_CONFIG_POLICY
unset CC2_ENDORSING_PEERS
unset CC2_ENV_FOLDER



echo "# Chaincode Environment Initialized!!!" > $DIR/cc.env.sh
set-chain-env.sh -z 

echo "Execute 'show-chain-env.sh' to see current Chaincode Environment Setup."
echo "Execute 'set-chain-env.sh' to set Chaincode Environment Setup."