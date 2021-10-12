package main

import (
	"log"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

func main() {
	todoChaincode, err := contractapi.NewChaincode(&chaincode.SmartContract{})
	if err != nil {
		log.Panicf("Error: %v", err)
	}

	if err := todoChaincode.Start(); err != nil {
		log.Panicf("Error: %v", err)
	}
}
