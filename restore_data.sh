#!/usr/bin/env bash

# Restore backuped date into mailman.
# Takes the backup file name (A tar file) as argument.

mkdir ./backup_temp
# Extract the Tar file into backup_temp:
tar -xvf $1 -C ./backup_temp

# Backup the data, lists and archives mailman directories
# by copying them to backup_temp directory on the host:
docker run --name mailman_data_restore \
        -v ./backup_temp:/backup \
        mailman_data \
        cp -R /var/lib/mailman/data /backup/data && \
        cp -R /var/lib/mailman/lists /backup/lists && \
        cp -R /var/lib/mailman/archives /backup/archives && \

docker rm -f mailman_data_restore

rm -R ./backup_temp
