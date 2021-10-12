package contract

import (
	"encoding/json"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// Smart Contract struct
type SmartContract struct {
	contractapi.Contract
}

// Business struct
type Todo struct {
	ID           string `json:"ID"`
	Title        string `json:"title"`
	Done         bool   `json:"done"`
	Creator      string `json:"creator"`
	Organization string `json:"organization"`
}

// Create new todo item
func (s *SmartContract) Create(ctx contractapi.TransactionContextInterface,
	id string,
	title string,
	creator string,
	organization string) error {
	todo := Todo{
		ID:           id,
		Title:        title,
		Done:         false,
		Creator:      creator,
		Organization: organization,
	}

	todoJSON, err := json.Marshal(todo)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(id, todoJSON)
}

// Read a todo item
func (s *SmartContract) Read(ctx contractapi.TransactionContextInterface, id string) (*Todo, error) {
	todoJSON, err := ctx.GetStub().GetState(id)
	if err != nil {
		return nil, err
	}

	var todo Todo
	if err := json.Unmarshal(todoJSON, &todo); err != nil {
		return nil, err
	}

	return &todo, nil
}

// Update a todo item
func (s *SmartContract) Update(ctx contractapi.TransactionContextInterface,
	id string,
	title string,
	creator string,
	organization string) error {
	todo := Todo{
		ID:           id,
		Title:        title,
		Creator:      creator,
		Organization: organization,
	}

	todoJSON, err := json.Marshal(todo)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(id, todoJSON)
}

// Delete a todo item
func (s *SmartContract) Delete(ctx contractapi.TransactionContextInterface, id string) error {
	return ctx.GetStub().DelState(id)
}

// Set status of todo item to "done"
func (s *SmartContract) SetDone(ctx contractapi.TransactionContextInterface, id string) error {
	todo, err := s.Read(ctx, id)
	if err != nil {
		return err
	}

	todo.Done = true
	todoJSON, err := json.Marshal(todo)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(id, todoJSON)
}

// Get all todo items
func (s *SmartContract) GetAll(ctx contractapi.TransactionContextInterface) ([]*Todo, error) {
	res, err := ctx.GetStub().GetStateByRange("", "")
	defer res.Close()

	if err != nil {
		return nil, err
	}

	var todos []*Todo

	for res.HasNext() {
		todoJSON, err := res.Next()
		if err != nil {
			return nil, err
		}

		var todo Todo
		if err := json.Unmarshal(todoJSON.Value, &todo); err != nil {
			return nil, err
		}

		todos = append(todos, &todo)
	}
	return todos, nil
}
