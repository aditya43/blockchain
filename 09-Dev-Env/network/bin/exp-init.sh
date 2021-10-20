#!/bin/bash

SLEEP_TIME=10s

# Fix for permission issue - v1-4.1.1
docker exec -d explorer chmod 755 /home/vagrant/bins/start.sh 
docker exec -d explorer chmod 755 /home/vagrant/bins/stop.sh 
docker exec -d explorer chmod 755 /home/vagrant/bins/status.sh 
docker exec -d explorer chmod 755 /home/vagrant/bins/regen-db.sh 
docker exec -d explorer chmod 755 /home/vagrant/bins/logs.sh 


# Regenerates the explorer database
docker exec -d explorer /home/vagrant/bins/stop.sh &> /dev/null

echo  "====>Starting Explorer DB Regeneration"
docker exec -d explorer   /home/vagrant/bins/regen-db.sh  &> /dev/null

sleep  $SLEEP_TIME

echo "===>Starting explorer....please wait"
docker exec -d explorer /home/vagrant/bins/start.sh
sleep  $SLEEP_TIME

echo "==> Explorer Console logs ====="

EXPLORER_STATUS=$(docker exec -it explorer /home/vagrant/bins/logs.sh)

sleep  5s

echo $EXPLORER_STATUS