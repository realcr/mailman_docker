#!/usr/bin/env bash

# Restore backuped date into mailman.
# Takes the backup file name (A tar file) as argument.

# Abort on failure.
set -e

# Check if mailman_server_cont is running. If it does,
# we will abort. We don't want to change the data while the server
# container is running.
nlines_server=`docker ps | grep mailman_server_cont | wc -l`
if [ "$nlines_server" -gt "0" ]
	then echo "mailman_server_cont is still running! Aborting data restore." && \
		exit
fi

echo "Restoring..."

BACK_DIR="backup_temp"

# Extract the Tar file into backup_temp:
tar -xvf $1 -C ./ > /dev/null

# Backup the data, lists and archives mailman directories
# by copying them to backup_temp directory on the host:
docker run --name mailman_data_restore_cont \
	--volumes-from mailman_data_cont \
	-v $(readlink -f $BACK_DIR):/backup \
        mailman_data \
	sh -c "\
	rm -rfv /var/lib/mailman/data/* && \
	rm -rfv /var/lib/mailman/lists/* && \
	rm -rfv /var/lib/mailman/archives/* && \
        cp -pR /backup/data /var/lib/mailman && \
        cp -pR /backup/lists /var/lib/mailman && \
        cp -pR /backup/archives /var/lib/mailman "

# Clean up: remove mailman_data_restore container:
docker rm -f mailman_data_restore_cont

# Remove the backups folder (We got it from opening the tar):
rm -R $BACK_DIR

# Unset abort on failure.
set +e
