#!/bin/bash

cp /home/vagrant/bins/config.json         /opt/explorer/app/platform/fabric/config.json
cp /home/vagrant/bins/explorerconfig.json /opt/explorer/app/explorerconfig.json

cd /opt/explorer


export DATABASE_HOST=postgresql

# node main.js &

./start.sh

# try some sleep here
sleep 10s

./syncstart.sh

sleep 5s
