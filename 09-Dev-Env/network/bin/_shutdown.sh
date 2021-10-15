#PEER_MODE=net
#Command=dev-init.sh -s 
#Generated: Fri Oct 15 12:25:06 UTC 2021 
docker-compose  -f ./compose/docker-compose.base.yaml     -f ./compose/docker-compose.couchdb.yaml     down 
