#!/bin/bash

# We want to replace some place holders with the right values.
# (We use the configuration files as templates of configuration files).
# See conf.sh for detailed information.

# Get environment variables from conf.sh:
# Using the -a setting we make sure that all variables
# will be automatically exported. This is needed for the envsubset 
# commands later.

set -a
source server.conf
set +a

# Replace environment variables with their value in some configuration files:
envsubst < "etc-mailman-mm_cfg.py" | sponge "etc-mailman-mm_cfg.py"
envsubst < "etc-postfix-transport" | sponge "etc-postfix-transport"
envsubst < "etc-apache2-sites-mailman-conf" | sponge "etc-apache2-sites-mailman-conf"
