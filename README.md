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
- [Blockchain Technology Benefits](#blockchain-technology-benefits)
- [Smart Contracts](#smart-contracts)
- [Development Environment Setup](#development-environment-setup)

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

-----------

## Blockchain Technology Benefits
- **Security**:
    * Since Blockchain is a distributed concensus based architecture, it's eliminates single point of failure and reduces the need for data intermediaries such as transfer agents or messaging system operators.
    * It helps prevent frauds and malicious third parties from doing bad things.
    * Its not fullproof and we do hear about hacks in the box or certainly in cryptocurrency or cryptocurrency exchanges but its very very difficult to hack or manipulate.
- **Transparency**:
    * It provides transparency and in place multialise standards, protocols and shared processes.
- **Trust**:
    * Its transparent and the immutable ledger makes it easy for different parties in a business network to collaborate, manage data and reach agreements.
- **Programmability**:
    * Its programmable, so its able to execute things like **smart contracts** and help be more tamper proof and have deterministic software that automates the business logic.
    * We can code to address many different things from governance to compliance, regulatory compliance, data privacy, identity, looking at things like "know your customer" types things or anti money laundring attributes.
    * It manages that stakeholder participation, like for things like proxy voting.
- **Privacy**:
    * It provides privacy.
- **High-Performance**:
    * It can be a private network of hybrid networks and they are engineered to sustain hundreds/millions of transactions per second and also handle periodic surges in network activity.
- **Scalability**:
    * Its highly scalable.
- **Authenticity and Scarcity**:
    * Digitization really ensures data integrity and enables acid profits. It's really a full transaction history in that single shared source of truth.
- **Streamlined Processes**:
    * Since it can automate almost everything, it can enable some more real time settlements, auditing, reporting and reduces processing times and the potential for error and the delays due to number of steps and intermediaries required to achieve the same level of confidence.
- **Economic Benefits**:
    * Reduced infrastructure, operational and transaction cost.
- **Market Reactivity**:
    * It can be very reactive to market.

-----------

## Smart Contracts
- **Contracts**:
    * A contract is formed when an **offer** by one party is **accepted** by the other party.
    * **Consideration** is the price paid for the promise of the other party. The price may not necessarily involve money.
        - For e.g. If you walk my dog, i will feed your cat.
        - For e.g. If you walk my dog, i will pay you 15 Rs.
- **Smart Contracts**:
    ```go
    Contract terms are agreed to ----> Smart Contract placed on the Blockchain ----> Triggering event causes contract to be automatically executed
    ```
    * **Contract terms are agreed to**: Hard coded and cannot be changed without both parties being aware.
    * **Smart Contract placed on the Blockchain**: Public viewed and verified.
    * **Triggering event causes contract to be automatically executed**: If/then statement coding.

-----------

## Development Environment Setup
- Install `Oracle Virtual Box` [https://www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads).
- Install `Vagrant` [https://www.vagrantup.com/downloads](https://www.vagrantup.com/downloads).
```sh
# Initialize vagrant and create Vagrantfile
vagrant init

# +-+-+-+-+-+-+-+-+ Configure Vagrantfile +-+-+-+-+-+-+-+-+
# Checkout boxes at: https://vagrantcloud.com/search
config.vm.box = "generic/ubuntu2010"

# Setup network
config.vm.network "private_network", ip "192.168.33.10"

# Mount folder
config.vm.synced_folder "./mount", "/home/vagrant/mount"

# Configure memory
config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.memory = "10000" #10 GB
end
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

# Bootup our virtual linux box
vagrant up

# SSH into our running virtual linux box
vagrant ssh

# +-+-+-+-+-+-+- Install HLF Pre-Requisites +-+-+-+-+-+-+-+
# https://hyperledger-fabric.readthedocs.io/en/release-1.4/prereqs.html
# install git
sudo apt install  git -y

# install curl
sudo apt install curl -y

# install docker
sudo apt install build-essential -y
sudo apt install apt-transport-https ca-certificates gnupg-agent software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose -y
sudo usermod -aG docker $USER
newgrp docker

# install go
curl -o "go.tar.gz" https://storage.googleapis.com/golang/go1.17.1.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf "go.tar.gz"

export PATH=$PATH:/usr/local/go/bin
source ~/.bashrc

# install node
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt install nodejs -y

# install ohmyzsh
# NOTE: Default password for root account on ubuntu: vagrant
sudo apt install zsh -y
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
- Install Samples, Binaries and Docker Images:
```sh
# SSH into vagrant
vagrant ssh

# Go to /mount directory
cd mount

# Install samples, binaries and docker images
curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.2.4 1.5.2
```
- Install `SSH` plugin for VSCode.
- While vagrant machine is up and running, execute following to get location of `IdentityFile`:
```sh
vagrant ssh-config
```
- Add new SSH host into VSCode SSH plugin:
```sh
# Host can be found in Vagrantfile. Look for following line:
# config.vm.network "private_network", ip: "192.168.33.10"
ssh vagrant@192.168.33.10 -i "C:/Aditya/Projects/HLF/.vagrant/machines/default/virtualbox/private_key"
```