#!/bin/bash

# test if container is running (as parameter 1)

# result will contain my-nginx if running, or null otherwise
result=$(docker ps | grep -ow $1)

if [ -z "$result" ]
	then
	echo "$1 isn't running"
	exit
fi

echo "stopping $1"
docker stop $1




