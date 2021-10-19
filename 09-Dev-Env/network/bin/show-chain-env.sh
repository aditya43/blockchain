#!/bin/bash

# Dumps the chaincode env variables "OR('BudgetMSP.member')"

DIR="$( which set-chain-env.sh)"
DIR="$(dirname $DIR)"
# echo $DIR
source $DIR/to_absolute_path.sh
# Read the current setup
cat   $DIR/cc.env.sh


