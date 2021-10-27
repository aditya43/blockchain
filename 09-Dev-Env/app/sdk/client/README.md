cred-store.js
=============
Sets up the credentials store under the subfolder ./keystore
The location of the storage is defined in the client section

Use this as a utility for managing user contexts on filesystem

Usage:
node  cred-store.js    acme   Admin


peer-queries.js
===============
Gets the instance of the peer class & uses it for querying the peer:
1. Gets the channels joined
2. Gets the chaincode installed
3. Gets the peers in gossip network

Usage:
node  peer-queries.js

channel-queries.js
==================
Requires the Chain to have atleast 3 blocks
1. Gets the info on the chain
2. Gets info for 2 latest blocks
3. Gets info for the instantiated chaincodes

Usage:
node  channel-queries.js

events.js
=========
Demostrates the use of events API for Block/Chaincode events
1. Sets up the ChannelEventHub instance
2. Registers Block listener
3. Registers Chaincode Listener (erc20 & transfer event)

To test:
1. Launch the listener
node ./events.js

2. Invoke the transfer function on erc20

You should see Block/Chaincode events

3. Install a different chaincode and invoke it

You will see the Block event but not the chaincode event
