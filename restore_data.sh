#!/usr/bin/env bash

# Restore backuped date into mailman.
# Takes the backup file name (A tar file) as argument.

BACK_DIR="backup_temp"

# Extract the Tar file into backup_temp:
tar -xvf $1 -C ./

# Backup the data, lists and archives mailman directories
# by copying them to backup_temp directory on the host:
docker run --name mailman_data_restore \
	--volumes-from mailman_data_cont \
	-v $(readlink -f $BACK_DIR):/backup \
        mailman_data \
	sh -c "\
        cp -R /var/lib/mailman/data /backup/data && \
        cp -R /var/lib/mailman/lists /backup/lists && \
        cp -R /var/lib/mailman/archives /backup/archives"

# Clean up: remove mailman_data_restore container:
docker rm -f mailman_data_restore

# Remove the backups folder (We got it from opening the tar):
rm -R $BACK_DIR
