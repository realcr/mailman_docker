#!/usr/bin/env bash

# Create the first list (mailman list) and set global site password.

# The assets will be mapped to /assets
# server.conf will be mapped to /assets/server.conf

# Abort on failure
set -e

# Source server.conf here, to get all the environment variables from it.
source /assets/server.conf

# Build the first mailing list (mailman). Without it mailman won't work.
# If it already exists, we won't build it.
newlist --urlhost=$MAILMAN_DOMAIN --emailhost=$MAILMAN_DOMAIN \
	mailman $MAILMAN_LIST_OWNER_MAIL $MAILMAN_LIST_OWNER_PASS

# Set the global site password (Used for web authentication)
mmsitepass $MAILMAN_SITE_PASS

# Unset abort on failure:
set +e
