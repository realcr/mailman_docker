#!/usr/bin/env bash

# Run server image (New mailman server) and copy what we get inside the 
# /var/lib/mailman/{data,lists,archives} directories.
# We will use this dir skeleton as the basic image of data_image.

rm -rf ./var_files

# Generate directories:
mkdir -p ./var_files/data
mkdir -p ./var_files/lists
mkdir -p ./var_files/archives


# Get the directories contents by running a new mailman_server:
docker run --name  gen_skeleton_cont \
        -v $(readlink -f ./var_files/data):/mm_vfiles/data \
        -v $(readlink -f ./var_files/lists):/mm_vfiles/lists \
        -v $(readlink -f ./var_files/archives):/mm_vfiles/archives \
        mailman_server \
        sh -c "\
        cp -R /var/lib/mailman/data /mm_vfiles && \
        cp -R /var/lib/mailman/lists /mm_vfiles && \
        cp -R /var/lib/mailman/archives /mm_vfiles"

# Cleanup the gen_skeleton_cont:
docker rm -f gen_skeleton_cont

# Remove the mailman_data_cont:
docker rm -f mailman_data_cont 2> /dev/null

# Build a new mailman_data_cont:
docker run --name mailman_data_cont \
       -v $(readlink -f ./var_files):/mm_vfiles \
       mailman_data \
       sh -c "\
       cp -R /mm_vfiles/data /var/lib/mailman && \
       cp -R /mm_vfiles/lists /var/lib/mailman && \
       cp -R /mm_vfiles/archives /var/lib/mailman && \
       rm -R /mm_vfiles/data && \
       rm -R /mm_vfiles/lists && \
       rm -R /mm_vfiles/archives"

rm -rf ./var_files
