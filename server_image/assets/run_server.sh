#!/usr/bin/env bash

# Run the server. (Assuming it is configured).

# Abort on failure:
set -e

# Finally we start the services of syslog-n, postfix, mailman and apache2.
service syslog-ng start
service postfix start
service mailman start
service apache2 start
# tail -F /var/log/mailman/*

# Unset abort on failure:
set +e
