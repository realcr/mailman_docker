#!/bin/sh

# We want to replace some place holders with the right values.
# (We use the configuration files as templates of configuration files).
# See conf.sh for detailed information.

# Get environment variables:
source conf.sh

# Replace environment variables with their value in some configuration files:
envsubst < "etc-mailman-mm_cfg.py" > "etc-mailman-mm-cfg.py"
envsubst < "etc-postfix-transport" > "etc-postfix-transport"
envsubst < "etc-apache2-sites-mailman-conf" > "etc-postfix-transport"
