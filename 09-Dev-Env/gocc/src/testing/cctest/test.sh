#!/bin/bash

# Requires the Fabric environment to be setup in net mode

# 1. Setup the chaincode env
set-chain-env.sh  -n   cctest
set-chain-env.sh  -p   testing/cctest   -v  1.0
source cc.env.sh

# 2. Include the unit test driver
source  utest.sh

# OPTIONAL - override the wait time after instantiate/invoke
# PS: Low value may lead to endorsement errors
# export TXN_WAIT_TIME=3s

# 3. Setup the logging spec - error is suggested
export FABRIC_LOGGING_SPEC='ERROR'

# 4. Generates a unique name everytime the script is executed
#    Comment this if you would like to use the same instance of
#    the chaincode *but* keep in mind that the state may change with every run

# Retain the original chaincode name otherwise it will be replaced by the random name !!
# Use this to set it back at the end of the test case implementation
# set-chain-env.sh -n $CC_ORIGINAL_NAME
CC_ORIGINAL_NAME=$CC_NAME
generate_unique_cc_name
set-chain-env.sh -n $CC_NAME
