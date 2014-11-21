#!/bin/bash

# We want to replace some place holders with the right values.
# (We use the configuration files as templates of configuration files).
# See conf.sh for detailed information.

# Get environment variables from conf.sh:
source conf.sh

# Replace environment variables with their value in some configuration files:
envsubst < "etc-mailman-mm_cfg.py" | sponge "etc-mailman-mm_cfg.py"
envsubst < "etc-postfix-transport" | sponge "etc-postfix-transport"
envsubst < "etc-apache2-sites-mailman-conf" | sponge "etc-apache2-sites-mailman-conf"
