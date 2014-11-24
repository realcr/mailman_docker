#!/usr/bin/env bash

# Stop the mailman server. We actually stop and remove the 
# mailman_server_cont container. The data persists inside the volumes.

# Abort on failure:
set -e

# Check if the mailman_server_cont container exists:
nlines_server_run=`docker ps -a | grep mailman_server_cont | wc -l`
if [ "$nlines_server_run" -eq "0" ]
	then echo "The mailman_server_cont container does not exist.
Aborting." && \
		exit
fi

# Check if mailman_server_cont is running. 
# If it is not running, we abort.
nlines_server_run=`docker ps | grep mailman_server_cont | wc -l`
if [ "$nlines_server_run" -eq "0" ]
	then echo "Note that mailman_server_cont is currently not running.
Removing the container..."
fi


# Remove the mailman server container:
docker rm -f mailman_server_cont

# Unset abort on failure.
set +e
