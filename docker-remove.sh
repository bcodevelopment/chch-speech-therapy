#!/bin/bash

# test if container is running (as parameter 1)

# result will contain my-nginx if running, or null otherwise
result=$(docker ps --filter status=exited | grep -ow $1)

if [ -z "$result" ]
	then
	echo "$1 doesn't exit"
	exit
fi

echo "removing $1"
docker rm $1




