#!/usr/bin/env bash

# Build mailman_data and mailman_server images.

docker build -t mailman_server ./server_image
docker build -t mailman_data ./data_image
