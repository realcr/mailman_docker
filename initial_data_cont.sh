#!/usr/bin/env bash

# Run server image (New mailman server) and copy what we get inside the 
# /var/lib/mailman/{data,lists,archives} directories.
# We will use this dir skeleton as the basic image of data_image.

# Generate directories:
mkdir ./var_files
mkdir ./var_files/data
mkdir ./var_files/lists
mkdir ./var_files/archives

# Get the directories contents by running a new mailman_server:
docker run --name gen_skeleton_cont \
       -v ./var_files/data:/var/lib/mailman/data \
       -v ./var_files/lists:/var/lib/mailman/lists \
       -v ./var_files/archives:/var/lib/mailman/archives \
        mailman_server

# Cleanup the gen_skeleton_cont:
docker rm -f gen_skeleton_cont

# Remove the mailman_data_cont:
docker rm -f mailman_data_cont

# Build a new mailman_data_cont:
docker run --name mailman_data_cont \
        -v ./var_files:/mm_vfiles \
        mailman_data \
        mkdir -p /var/lib/mailman && \
        mv -R /mm_vfiles/data /var/lib/mailman/data && \
        mv -R /mm_vfiles/lists /var/lib/mailman/lists && \
        mv -R /mm_vfiles/archives /var/lib/mailman/archives && \
        rm -R /mm_vfiles
