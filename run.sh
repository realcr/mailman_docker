#!/bin/sh

# Run mailman with the relevant environment variables.

docker run \
-e MAILMAN_DOMAIN=lists.freedomlayer.org \
-e MAILMAN_SITE_PASS=123456 \
-e MAILMAN_LIST_OWNER_MAIL=real.flayer@outlook.com \
-e MAILMAN_LIST_OWNER_PASS=123456 \
-d -p 25:25 -p 80:80 \
--name mailman \
-h lists.freedomlayer.org \
mymail
