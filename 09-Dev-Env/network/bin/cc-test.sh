#!/bin/bash
# Picks up the CC_PATH from the chaincode environment

function usage {
    echo    "Usage: cc-test.sh   [TEST-File-Name  default=test.sh]"
    echo    "Looks for the test file under the path $GOPATH/$CC_PATH/TEST-File-Name.sh"
}

TEST_FILE_NAME=test.sh

if [ "$1" != "" ]; then
    TEST_FILE_NAME=$1
fi

# Pull in the chaincode environment
source cc.env.sh

# Pending
# Check if test file name ends with .sh? if not suffix .sh
FULL_TEST_FILE_PATH=$GOPATH/src/$CC_PATH/$TEST_FILE_NAME
echo "Running Test Using:  $FULL_TEST_FILE_PATH"

$FULL_TEST_FILE_PATH