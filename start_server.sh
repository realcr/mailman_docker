#!/usr/bin/env bash

# Start the mailman server, and connect it with the volumes 
# inside the data container.

# Abort on failure:
set -e

# Get the directories contents by running a new mailman_server:
docker run -d --name  mailman_server_cont \
        -p 80:80 -p 25:25 \
	--volumes-from mailman_data_cont \
        mailman_server

# Unset abort on failure.
set +e
