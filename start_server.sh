#!/usr/bin/env bash

# Start the mailman server, and connect it with the volumes 
# inside the data container.

# Abort on failure:
set -e

# Check if mailman_server_cont is running. 
# If it is running, we abort.
nlines_server=`docker ps | grep mailman_server_cont | wc -l`
if [ "$nlines_server" -gt "0" ]
	then echo "mailman_server_cont is already running! Aborting." && \
		exit
fi

# Get the environment variables from conf.sh
source ports.conf

# Get the directories contents by running a new mailman_server:
docker run -d --name  mailman_server_cont \
        -p ${EXT_HTTP_PORT}:80 -p ${EXT_SMTP_PORT}:25 \
	-v $(readlink -f ./conf.sh):/assets/conf.sh \
	--volumes-from mailman_data_cont \
        mailman_server

# Unset abort on failure.
set +e
