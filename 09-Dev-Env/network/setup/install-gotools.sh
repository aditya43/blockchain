#!/bin/bash
# Updated : Fabric 2.x : April 2020

echo "Installing govendor....please wait"

# Changes the object owner for all folder under $HOME
sudo find ~ -user root -exec sudo chown $USER: {} +

# Installs the tools for Go
# https://github.com/kardianos/govendor/wiki/Govendor-CheatSheet
go get -u github.com/kardianos/govendor

# Install the package for the protocol
# ./install-protoc.sh

# echo "export PATH=$PATH:$GOPATH/bin" >> ~/.profile
./update-git-repo.sh

echo "Done. Logout and Log back in"
