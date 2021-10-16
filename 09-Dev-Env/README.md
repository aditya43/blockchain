## Scripts to execute:
```sh
# ssh into vagrant box
vagrant ssh

# Go to vexpress install
cd /vagrant/network/setup/vexpress

# Initialize express install
./init-vexpress.sh

# Go to network binaries
cd /vagrant/network/bin

# Run dev init script
./dev-init.sh

# Validate dev environment. This will also install the chaincode on both the Peers.
./dev-validate.sh

# Set env variables for acme organization so we can run peer commands in it's context
. set-env.sh acme

# Execute peer lifecycle command in acme organization's context
peer lifecycle chaincode queryinstalled
```