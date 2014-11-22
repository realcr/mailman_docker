#!/usr/bin/env bash

# Backup data from the mailman data container.

mkdir ./backup_temp

# Backup the data, lists and archives mailman directories
# by copying them to backup_temp directory on the host:
docker run --name mailman_data_backup \
        -v ./backup_temp:/backup \
        mailman_data \
	rm -R /var/lib/mailman/data && \
	rm -R /var/lib/mailman/lists && \
	rm -R /var/lib/mailman/archives && \
        cp -R /backup/data /var/lib/mailman/data  && \
        cp -R /backup/lists /var/lib/mailman/lists  && \
        cp -R /backup/archives var/lib/mailman/archives

# Clean up docker container:
docker rm -f mailman_data_backup

# Create a tar archive (With the current date):
now = $(date + "%m_%d_%Y")
tar -cvf ./backup_${now}.tar ./backup_temp

rm -R ./backup_temp
