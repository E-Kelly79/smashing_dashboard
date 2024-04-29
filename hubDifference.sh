#!/bin/bash

# Script will show any difference between current RM Docker specification and its equivalent 
# in Docker Hub. For more details on how to use this script:
# https://github.com/RouteMatch/docs/wiki/builddockerimages#maintaining-routematch-modified-official-docker-hub-specifications

# Specify the URL for the Docker Hub location of the Docker specification.
# Since they are usually in GitHub ensure that the raw URL is used.
#DOCKER_HUB_SPEC_URL=

# Specify the URL for the Docker Hub location of the Docker image start script.
# Since they are usually in GitHub ensure that the raw URL is used.
#DOCKER_STARTUP_SCRIPT=

# Specify temporary download location. Avoid using the current Git repository.
TEMP_LOCATION=$HOME/temp
# Specify the name of the downloaded Docker specification
TEMP_DOCKER_FILENAME=$(basename $(pwd)).docker
# Specify the name of the downloaded Docker image start script
#TEMP_SCRIPT_FILENAME=$(basename $(pwd)).script

# Ensure that temporary location exists
if [ ! -d $TEMP_LOCATION ] 
then
	mkdir $TEMP_LOCATION
fi

# Download the Docker Hub specification
wget -O $TEMP_LOCATION/$TEMP_DOCKER_FILENAME $DOCKER_HUB_SPEC_URL

# Download the Docker Hub specification
#wget -O $TEMP_LOCATION/$TEMP_SCRIPT_FILENAME $DOCKER_STARTUP_SCRIPT

echo
echo "Docker specification differences"
echo "Current RouteMatch version on left"
echo "================================"
echo
# Default difference presentation is side-by-side
diff -y Docker/Dockerfile $TEMP_LOCATION/$TEMP_DOCKER_FILENAME

echo
echo "Docker startup script differences"
echo
# Default difference presentation is side-by-side
#diff -y Docker/??? $TEMP_LOCATION/$TEMP_SCRIPT_FILENAME
