#!/usr/bin/env bash

# Backup data from the mailman data container.

BACK_DIR="backup_temp"

mkdir -p ./${BACK_DIR}/data
mkdir -p ./${BACK_DIR}/lists
mkdir -p ./${BACK_DIR}/archives

# Backup the data, lists and archives mailman directories
# by copying them to backup_temp directory on the host:
docker run --name mailman_data_backup \
	--volumes-from mailman_data_cont \
	-v $(readlink -f $BACK_DIR):/backup \
        mailman_data \
	sh -c "\
        cp -R /var/lib/mailman/data /backup && \
        cp -R /var/lib/mailman/lists /backup && \
        cp -R /var/lib/mailman/archives /backup"

# Clean up docker container:
docker rm -f mailman_data_backup

# Create a tar archive (With the current date):
now=$(date +%m_%d_%Y)
tar -cvf ./backup_${now}.tar $BACK_DIR

rm -R $BACK_DIR
