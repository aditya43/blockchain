#PEER_MODE=net
#Command=dev-init.sh -s 
#Generated: Sat Nov  6 10:55:00 UTC 2021 
docker-compose  -f ./compose/docker-compose.base.yaml     -f ./compose/docker-compose.couchdb.yaml     down 
