#!/usr/bin/env bash

# Stop the mailman server. We actually stop and remove the 
# mailman_server_cont container. The data persists inside the volumes.

# Abort on failure:
set -e

# Check if mailman_server_cont is running. 
# If it is not running, we abort.
nlines_server=`docker ps | grep mailman_server_cont | wc -l`
if [ "$nlines_server" -eq "0" ]
	then echo "mailman_server_cont is not running! Aborting." && \
		exit
fi

# Remove the mailman server container:
docker rm -f mailman_server_cont

# Unset abort on failure.
set +e
