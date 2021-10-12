package main

import (
	"log"
	"todo/contract"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

func main() {
	todoChaincode, err := contractapi.NewChaincode(&contract.SmartContract{})
	if err != nil {
		log.Panicf("Error: %v", err)
	}

	if err := todoChaincode.Start(); err != nil {
		log.Panicf("Error: %v", err)
	}
}
