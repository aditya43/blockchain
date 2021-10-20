#!/bin/bash

nc -w2 explorer 8080
# </dev/tcp/localhost/8580

# 0=success 1=failure
STATUS=$?

echo $STATUS

if [ "$STATUS" == '0' ]; then
    echo "Fabric Explorer is 'up'"
else
    echo "Fabric Explorer is 'down'"
fi
