package contract

import "github.com/hyperledger/fabric-contract-api-go/contractapi"

type SmartContract struct {
	contractapi.Contract
}

type Asset struct{}

func (s *SmartContract) adi(ctx contractapi.TransactionContextInterface) error {
	return nil
}
