#!/bin/bash
#To be used only with express setup

if [ ! -d "$HOME/goccbup/gocc" ]; then
    echo "This script works only with the 'Virtual Box Express' install !!!"
    exit
fi

LOCT=$HOME/goccbup/gocc
# copy the pkg
echo "Setting up Shim & Go Binaries"
mkdir -p $GOPATH/pkg
cp -r $LOCT/pkg $GOPATH
mkdir -p $GOPATH/bin
cp -r $LOCT/bin $GOPATH

echo "Setting up Fabric & Golang Libraries"
cp -r $LOCT/src/github.com $GOPATH/src
cp -r $LOCT/src/golang.org $GOPATH/src
cp -r $LOCT/src/google.golang.org $GOPATH/src

# Overwrite sample only if needed
function update_sample {
    if [ ! -d "$GOPATH/src/$SAMPLE_NAME" ]; then
        echo "Adding Sample : $SAMPLE_NAME"
        cp -r $LOCT/src/$SAMPLE_NAME $GOPATH/src
    else
        echo "Skipping as already setup : $SAMPLE_NAME"
    fi
}

SAMPLE_NAME="acflogger"
update_sample

SAMPLE_NAME="chaincode_example02"
update_sample

SAMPLE_NAME="snippets"
update_sample

SAMPLE_NAME="token"
update_sample

SAMPLE_NAME="testing"
update_sample

echo "."
echo "You may always update the Code repository by executing the script:"
echo "> cd  network/setup"
echo "> ./update-git-repo.sh"
echo "You may vaidate the setup by running the script:"
echo "> cd network/setup"
echo "> ./validate-setup.sh"
echo "All Done !!!"