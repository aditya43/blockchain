/**
 * Demonstrates the use of Gateway Network & Contract classes
 */

 // Needed for reading the connection profile as JS object
const fs = require('fs');
// Used for parsing the connection profile YAML file
const yaml = require('js-yaml');
// Import gateway class
const { Gateway, FileSystemWallet, DefaultEventHandlerStrategies, Transaction  } = require('fabric-network');

// Constants for profile
const CONNECTION_PROFILE_PATH = '../profiles/dev-connection.yaml'
// Path to the wallet
const FILESYSTEM_WALLET_PATH = './user-wallet'
// Identity context used
const USER_ID = 'Admin@acme.com'
// Channel name
const NETWORK_NAME = 'airlinechannel'
// Chaincode
const CONTRACT_ID = "erc20"



// 1. Create an instance of the gatway
const gateway = new Gateway();

// Sets up the gateway | executes the invoke & query
main()

/**
 * Executes the functions for query & invoke
 */
async function main() {

    // 2. Setup the gateway object
    await setupGateway()

    // 3. Get the network
    let network = await gateway.getNetwork(NETWORK_NAME)
    // console.log(network)

       // 5. Get the contract
    const contract = await network.getContract(CONTRACT_ID);
    // console.log(contract)

    // 6. Query the chaincode
    await queryContract(contract)

    // 7. Execute the transaction
    await submitTxnContract(contract)
    // Must give delay or use await here otherwise Error=MVCC_READ_CONFLICT
    // await submitTxnContract(contract)

}

/**
 * Queries the chaincode
 * @param {object} contract
 */
async function queryContract(contract){
    try{
        // Query the chaincode
        let response = await contract.evaluateTransaction('balanceOf', 'john')
        console.log(`Query Response=${response.toString()}`)
    } catch(e){
        console.log(e)
    }
}

/**
 * Submit the transaction
 * @param {object} contract
 */
async function submitTxnContract(contract){
    try{
        // Submit the transaction
        let response = await contract.submitTransaction('transfer', 'john','sam','2')
        console.log("Submit Response=",response.toString())
    } catch(e){
        // fabric-network.TimeoutError
        console.log(e)
    }
}

/**
 * Function for setting up the gateway
 * It does not actually connect to any peer/orderer
 */
async function setupGateway() {

    // 2.1 load the connection profile into a JS object
    let connectionProfile = yaml.safeLoad(fs.readFileSync(CONNECTION_PROFILE_PATH, 'utf8'));

    // 2.2 Need to setup the user credentials from wallet
    const wallet = new FileSystemWallet(FILESYSTEM_WALLET_PATH)

    // 2.3 Set up the connection options
    let connectionOptions = {
        identity: USER_ID,
        wallet: wallet,
        discovery: { enabled: false, asLocalhost: true }
        /*** Uncomment lines below to disable commit listener on submit ****/
        // , eventHandlerOptions: {
        //     strategy: null
        // }
    }

    // 2.4 Connect gateway to the network
    await gateway.connect(connectionProfile, connectionOptions)
    // console.log( gateway)
}



/**
 * Creates the transaction & uses the submit function
 * Solution
 * To execute this add the line in main() => submitTxnTransaction(contract)
 * @param {object} contract
 */
// async function submitTxnTransaction(contract) {
//     // Provide the function name
//     let txn = contract.createTransaction('transfer')

//     // Get the name of the transaction
//     console.log(txn.getName())

//     // Get the txn ID
//     console.log(txn.getTransactionID())

//     // Submit the transaction
//     try{
//         let response = await txn.submit('john', 'sam', '2')
//         console.log("transaction.submit()=", response.toString())
//     } catch(e) {
//         console.log(e)
//     }
// }