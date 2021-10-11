const {Wallets, Gateway} = require('fabric-network');

const fs = require('fs');
const path = require('path');

async function main() {
    try {
        // Load the network configuration
        const ccpPath = path.resolve(__dirname, '..', 'network', 'organizations', 'peerOrganizations', 'org1.example.com', 'connection-org1.json');
        const ccp = JSON.parse(fs.readFileSync(ccpPath, 'urf8'));

        // Create a new file system based wallet for managing identities
        const walletPath = path.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);

        // Create gateway
        const gateway = new Gateway();
        await gateway.connect(ccp, {wallet, identity: 'appUser', discovery: {enabled: true, asLocalhost: true}});

        // Create network object
        const network = await gateway.getNetwork('channel1');

        // Create contract object
        const contract = network.getContract('fabcar');

        // Query and display results
        const res = await contract.evaluateTransaction('queryAllCars');
        console.log(`Result: ${res.toString()}`);

        // Disconnect from gateway
        await gateway.disconnect();

        console.log('Success!');
    } catch (e) {
        console.error(`Error: ${e}`);
        process.exit(1);
    }
}

main();