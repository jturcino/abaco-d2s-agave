#! /bin/bash

echo ""
echo "CLEANING UP"

# get container
if [ -z "$1" ]; then
    echo "No container name provided for cleanup."
    exit 1
fi
container="$1"

# remove container by id
id="$(docker images -q $container)"
docker rmi -f $id
