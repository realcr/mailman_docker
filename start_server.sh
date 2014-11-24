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

# Check if mailman_data_cont exists. If it doesn't exist, we abort.
nlines_data=`docker ps -a | grep mailman_data_cont | wc -l`
if [ "$nlines_data" -eq "0" ]
	then echo "Missing mailman_data_cont container! Aborting. Please run
initial_data_cont first." && \
		exit
fi

# Get the environment variables from server.conf:
source server.conf

# Get the directories contents by running a new mailman_server.
# We get the volumes from the mailman_data_cont container.
# We also map the configuration file server.conf, and the assets from
# ./server_image/assets
docker run -d --name  mailman_server_cont \
        -p ${EXT_HTTP_PORT}:80 -p ${EXT_SMTP_PORT}:25 \
	--volumes-from mailman_data_cont \
	-v $(readlink -f ./server_image/assets):/raw_assets \
	-v $(readlink -f ./server.conf):/raw_assets/server.conf \
        mailman_server sh -c "chmod +x /assets/*.sh && \
				/assets/conf_server.sh && \
				/assets/run_server.sh && \
				tail -F /var/log/mailman/*"

echo "Server serves HTTP on port $EXT_HTTP_PORT and SMTP on port $EXT_SMTP_PORT ."

# Unset abort on failure.
set +e

