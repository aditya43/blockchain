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
