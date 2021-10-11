const FabricCAServices = require('fabric-ca-client');
const {Wallets, Wallet} = require('fabric-network');

const fs = require('fs');
const path = require('path');

async function main() {
    try {
        // Load the network configuration
        const ccpPath = path.resolve(__dirname, '..', 'network', 'organizations', 'peerOrganizations', 'org1.example.com', 'connection-org1.json');
        const ccp = JSON.parse(fs.readFileSync(ccpPath, 'urf8'));

        // Create the CA client for interacting with the CA
        const caInfo = ccp.certificateAuthorities['ca.org1.example.com'];
        const ca = new FabricCAServices(caInfo.url);

        // Create a new file system based wallet for managing identities
        const walletPath = path.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);

        // Build the admin object for CA
        const adminIdentity = await wallet.get('admin');
        const provider = wallet.getProviderRegistry().getProvider(adminIdentity.type);
        const adminUser = await provider.getUserContext(adminIdentity, 'admin');

        // Register, Enroll and Import the identity
        const secret = await ca.register({affiliation: 'org1.department1', enrollmentID: 'appUser', role: 'client'}, adminUser);
        const enrollment = await ca.enroll({enrollmentID: 'appUser', enrollmentSecret: secret});
        const x509Identity = {credentials: {certificate: enrollment.certificate, privateKey: enrollment.key.toBytes()}, mspId: 'Org1MSP', type: 'X.509'};

        await wallet.put('appUser', x509Identity);
    } catch (e) {
        console.error(`Error: ${e}`);
        process.exit(1);
    }
}

main();