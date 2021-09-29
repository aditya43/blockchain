# Blockchain
Blockchain, Hyperledger Fabric, Chain Code, Smart Contracts, Golang, CouchDB etc. My personal notes, example codes, best practices and sample projects.

## Author
Aditya Hajare ([Linkedin](https://in.linkedin.com/in/aditya-hajare)).

## Current Status
WIP (Work In Progress)!

## License
Open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT).

-----------

## Important Notes
- [Blockchain Basics](#blockchain-basics)

-----------
## Blockchain Basics
- It is a decentralized system. Decentralized means the network is **powered by its users (Peers)** without having any third party, central authority or middleman controlling it.
- Every Peer has a record of the complete history of all transactions as well as the balance of every account.
- This bookkeeping is not controlled by one party or a central authority (E.g. Central Bank).
- Its all Public, and available in one digital ledger which is fully distributed across the network. i.e. everybody sees what everybody is doing.
- The Blockchain acts as a public ledger.
- In blockchain all the transactions are logged including:
    * Time
    * Date
    * Participants
    * Amount of every single transaction
- Each node in the network owns the full copy of the blockchain.
- The nodes automatically and continuously agree about the current state of the ledger and every transaction in it.
- If anyone attempts to currupt a transaction, the nodes will not arrive at a **consensus** and hence will refuse to incorporate the transaction in the blockchain.
- So every transaction is public and thousands of nodes unanimously agreed that a transaction has occurred on date X at time Y.
- Everyone has access to shared single public source of truth.