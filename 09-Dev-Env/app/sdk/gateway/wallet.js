/**
 * Demostrates the use of wallet API
 * 
 * Utility for managing the wallet for users.
 */

// Using it for files access
const fs = require('fs');
const path = require('path');
// Import the classes for managing file system wallet
const { FileSystemWallet, X509WalletMixin } = require('fabric-network');

// Location of the crypto for the dev environment
const CRYPTO_CONFIG = path.resolve(__dirname, '../../../network/crypto/crypto-config');
const CRYPTO_CONFIG_PEER_ORGS = path.join(CRYPTO_CONFIG, 'peerOrganizations')

// Folder for creating the wallet - All identities written under this
const WALLET_FOLDER = './user-wallet'

// Create an instance of the file system wallet
const wallet = new FileSystemWallet(WALLET_FOLDER);

// Get the requested action
let action='list'
if (process.argv.length > 2){
    action = process.argv[2]
}

// Check on the action requested by user
if(action == 'list'){
    console.log("List of identities in wallet:")
    listIdentities()
} else if (action == 'add' || action == 'export'){
    if(process.argv.length < 5){
        console.log("For 'add' & 'export' - Org & User are needed!!!")
        process.exit(1)
    }
    if (action == 'add'){
        addToWallet(process.argv[3], process.argv[4])
        console.log('Done adding/updating.')
    } else {
        exportIdentity(process.argv[3], process.argv[4])
    }
} 

/**
 * @param   string  Organization = acme or budget
 * @param   string  User  = Admin   User1   that need to be added
 */
async function addToWallet(org, user) {
    // Read the cert & key file content
    try {
        // Read the certificate file content
        var cert = readCertCryptogen(org, user)

        // Read the keyfile content
        var key = readPrivateKeyCryptogen(org, user)

    } catch (e) {
        // No point in proceeding if the Certificate | Key can't be read
        console.log("Error reading certificate or key!!! "+org+"/"+user)
        process.exit(1)
    }

    // Create the MSP ID
    let mspId = createMSPId(org)

    // Create the label
    const identityLabel = createIdentityLabel(org,user);

    // Create the X509 identity 
    const identity = X509WalletMixin.createIdentity(mspId, cert, key);

    // Add to the wallet
    await wallet.import(identityLabel, identity);
}

/**
 * Lists/Prints the identities in the wallet
 */
async function listIdentities(){
    console.log("Identities in Wallet:")

    // Retrieve the identities in folder
    let list = await wallet.list()
 
    // Loop through the list & print label
    for(var i=0; i < list.length; i++) {
         console.log((i+1)+'. '+list[i].label)
    }
 
 }

 /**
 * Extracts the identity from the wallet
 * @param {string} org 
 * @param {string} user 
 */
async function exportIdentity(org, user) {
    // Label is used for identifying the identity in wallet
    let label = createIdentityLabel(org, user)

    // To retrive execute export
    let identity = await wallet.export(label)

    if (identity == null){
        console.log(`Identity ${user} for ${org} Org Not found!!!`)
    } else {
        // Prints all attributes : label, Key, Cert
        console.log(identity)
    }
}


/**
 * Reads content of the certificate
 * @param {string} org 
 * @param {string} user 
 */
function readCertCryptogen(org, user) {
    //budget.com/users/Admin@budget.com/msp/signcerts/Admin@budget.com-cert.pem"
    var certPath = CRYPTO_CONFIG_PEER_ORGS + "/" + org + ".com/users/" + user + "@" + org + ".com/msp/signcerts/" + user + "@" + org + ".com-cert.pem"
    const cert = fs.readFileSync(certPath).toString();
    return cert
}

/**
 * Reads the content of users private key
 * @param {string} org 
 * @param {string} user 
 */
function readPrivateKeyCryptogen(org, user) {
    // ../crypto/crypto-config/peerOrganizations/budget.com/users/Admin@budget.com/msp/keystore/05beac9849f610ad5cc8997e5f45343ca918de78398988def3f288b60d8ee27c_sk
    var pkFolder = CRYPTO_CONFIG_PEER_ORGS + "/" + org + ".com/users/" + user + "@" + org + ".com/msp/keystore"
    fs.readdirSync(pkFolder).forEach(file => {
        // console.log(file);
        // return the first file
        pkfile = file
        return
    })

    return fs.readFileSync(pkFolder + "/" + pkfile).toString()
}

/**
 * Utility function
 * Creates the MSP ID from the org name for 'acme' it will be 'AcmeMSP'
 * @param {string} org 
 */
function createMSPId(org) {
    return org.charAt(0).toUpperCase() + org.slice(1) + 'MSP'
}

/**
 * Utility function
 * Creates an identity label for the wallet
 * @param {string} org 
 * @param {string} user 
 */
function createIdentityLabel(org, user){
    return user+'@'+org+'.com';
}