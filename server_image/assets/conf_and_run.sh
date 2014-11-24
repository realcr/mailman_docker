#!/usr/bin/env bash

# Configure Mailman, Apache and Postfix using the 
# given configuration file. Finally, Start the server.

# Abort on failure:
set -e

# Getting the assets
# -------------------
# Copy the full assets directory (From the host machine):
# ADD ./assets /assets
# ADD ./server.conf /assets/server.conf


# The assets will be mapped to /assets
# server.conf will be mapped to /assets/server.conf

cd /assets

# Execution permissions:
chmod +x "/assets/apply_conf.sh"

# Replace environment variables with their value in some configuration files:
/assets/apply_conf.sh

# Source server.conf here, to get all the environment variables from it.
source server.conf

# Copy Mailman configuration file:
cp "/assets/etc-mailman-mm_cfg.py" "/etc/mailman/mm_cfg.py"

# Link mailman to apache
# -----------------------

# Get relevant apache configuration for mailmain:
# RUN ln -s /etc/mailman/apache.conf /etc/apache2/sites-available/mailman
cp "/assets/etc-apache2-sites-mailman-conf" "/etc/apache2/sites-available/mailman.conf"
# Create root site directory:
mkdir /var/www/lists

# Set the server name:
echo "ServerName localhost" > /etc/apache2/conf-available/fqdn.conf
a2enconf fqdn

# Enable CGI module in apache: (Required for mailman to work).
a2enmod cgi

# Remove the default apache sites:
# RUN a2dissite 000-default
# RUN a2dissite ssl-default # Seems like this site doesn't work at all.

# Enable the mailman virtual host:
a2ensite mailman

# Restart apache:
/etc/init.d/apache2 restart


# Configure postfix
# -------------------

# TODO: What is inside here? Should we fix it?
# cat /etc/mailname

postconf -e "relay_domains = $MAILMAN_DOMAIN"
postconf -e 'transport_maps = hash:/etc/postfix/transport'
postconf -e 'mailman_destination_recipient_limit = 1'
postconf -e 'alias_maps = hash:/etc/aliases, hash:/var/lib/mailman/data/aliases'

postconf -e "myhostname=$MAILMAN_DOMAIN"
postconf -e "mydestination=$MAILMAN_DOMAIN, localhost.localdomain, localhost"
postconf -e 'mail_spool_directory=/var/spool/mail/'
postconf -e 'mailbox_command='

# Add a local user to receive mail at someone@example.com, with a delivery directory
# (for the Mailbox format).
useradd -s /bin/bash someone
mkdir /var/spool/mail/someone
chown someone:mail /var/spool/mail/someone

cp /assets/etc-aliases.txt /etc/aliases

cp /assets/etc-postfix-transport /etc/postfix/transport
postmap -v /etc/postfix/transport

## Connect mailman to postfix
# ----------------------------

# Generate aliases:
/usr/lib/mailman/bin/genaliases

# Allow access to /var/lib/mailman/data/aliases
# See http://wiki.list.org/pages/viewpage.action?pageId=4030721
chmod 0664 /var/lib/mailman/data/aliases*

chown root:list /etc/postfix/transport

newaliases
/etc/init.d/postfix restart

## Supervisord configuration files:
# --------------------------------
cp /assets/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#########[ Start all processes] ##################

# Build the first mailing list (mailman). Without it mailman won't work.
# If it already exists, we won't build it.
newlist --urlhost=$MAILMAN_DOMAIN --emailhost=$MAILMAN_DOMAIN \
	mailman $MAILMAN_LIST_OWNER_MAIL $MAILMAN_LIST_OWNER_PASS || true

# Set the global site password (Used for web authentication)
mmsitepass $MAILMAN_SITE_PASS

# Move to the root directory:
cd /
# Cleanup the assets directory.
# rm -R /assets

# We have to change some permissions, because we get the mailman data from
# external volumes.

# We first change the permissions of /var/lib/mailman,
# because it is a volume that taken from the outside, and
# the volume has incorrect permissions.
chown root:list -R /var/lib/mailman
chmod -R g+w /var/lib/mailman

# Then we deal with the archives. We want to let apache browse the private folder,
# So we change the owner of private to www-data (Apache's user), and remove
# the execution permission.
chown www-data /var/lib/mailman/archives/private
chmod o-x /var/lib/mailman/archives/private

# Finally we start the services of syslog-n, postfix, mailman and apache2.
service syslog-ng start
service postfix start
service mailman start
service apache2 start
tail -F /var/log/mailman/*

# Unset abort on failure:
set +e
