# Taken from https://github.com/colmsjo/docker/tree/master/containers/mailman

FROM ubuntu:14.04
MAINTAINER real <real.flayer@outlook.com>

# run echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list # 2013-08-24

RUN apt-get update

# Good foor debugging
RUN apt-get -y install mutt vim dnsutils wget curl

# Language stuff:
RUN apt-get install -q -y language-pack-en
RUN update-locale LANG=en_US.UTF-8

RUN echo mail > /etc/hostname


######################## [Install Apache] #########################

RUN apt-get install -y apache2

######################## [Install mailman] ########################

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mailman

# Mailman configuration file:
ADD ./etc-mailman-mm_cfg.py /etc/mailman/mm_cfg.py

########################[ Link Mailman to Apache ] ##################

# Get relevant apache configuration for mailmain:
# RUN ln -s /etc/mailman/apache.conf /etc/apache2/sites-available/mailman
ADD etc-apache2-sites-mailman-conf /etc/apache2/sites-available/mailman.conf
# Create root site directory:
RUN mkdir /var/www/lists

# Enable CGI module in apache: (Required for mailman to work).
RUN a2enmod cgi

# Enable the mailman virtual host:
RUN a2ensite mailman

# Restart apache:
RUN /etc/init.d/apache2 restart


###############[ Install syslog-ng ]################################

# Use syslog-ng to get Postfix logs (rsyslog uses upstart which does not seem
# to run within Docker).

# Added syslog-ng-core to solve a problem here.
# Advice from: https://bugs.launchpad.net/ubuntu/+source/syslog-ng/+bug/1242173
RUN apt-get install -q -y syslog-ng syslog-ng-core

# Read more about the relation of postfix logging to syslog here:
# http://www.postfix.org/BASIC_CONFIGURATION_README.html#syslog_howto

# Taken from: https://registry.hub.docker.com/u/dockerbase/syslog-ng/dockerfile/
# Replace the system() source because inside Docker we can't access /proc/kmsg.
# https://groups.google.com/forum/#!topic/docker-user/446yoB0Vx6w
RUN sed -i -E 's/^(\s*)system\(\);/\1unix-stream("\/dev\/log");/' /etc/syslog-ng/syslog-ng.conf
# Uncomment 'SYSLOGNG_OPTS="--no-caps"' to avoid the following warning:
# syslog-ng: Error setting capabilities, capability management disabled; error='Operation not permitted'
# http://serverfault.com/questions/524518/error-setting-capabilities-capability-management-disabled#
RUN sed -i 's/^#\(SYSLOGNG_OPTS="--no-caps"\)/\1/g' /etc/default/syslog-ng

################# [Install Postfix] ############
RUN echo "postfix postfix/main_mailer_type string Internet site" > preseed.txt
RUN echo "postfix postfix/mailname string lists.freedomlayer.org" >> preseed.txt

# Use Mailbox format.
RUN debconf-set-selections preseed.txt
RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y postfix

RUN postconf -e 'relay_domains = lists.freedomlayer.org'
RUN postconf -e 'transport_maps = hash:/etc/postfix/transport'
RUN postconf -e 'mailman_destination_recipient_limit = 1'
RUN postconf -e 'alias_maps = hash:/etc/aliases, hash:/var/lib/mailman/data/aliases'

RUN postconf -e 'myhostname=lists.freedomlayer.org'
RUN postconf -e 'mydestination=lists.freedomlayer.org, localhost.localdomain, localhost'
RUN postconf -e 'mail_spool_directory=/var/spool/mail/'
RUN postconf -e 'mailbox_command='

# Add a local user to receive mail at someone@example.com, with a delivery directory
# (for the Mailbox format).
RUN useradd -s /bin/bash someone
RUN mkdir /var/spool/mail/someone
RUN chown someone:mail /var/spool/mail/someone

ADD etc-aliases.txt /etc/aliases

ADD ./etc-postfix-transport /etc/postfix/transport
RUN postmap -v /etc/postfix/transport

#################[ Connect mailman to postfix ]#####################

# Generate aliases:
RUN /usr/lib/mailman/bin/genaliases

# Allow access to /var/lib/mailman/data/aliases
# See http://wiki.list.org/pages/viewpage.action?pageId=4030721
RUN chmod 0664 /var/lib/mailman/data/aliases*

RUN chown root:list /etc/postfix/transport

RUN newaliases
RUN /etc/init.d/postfix restart

######### [Install supervidord] ################## 
# (used to handle processes)

RUN apt-get install -y supervisor
ADD ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#########[ Start all processes] ##################

# Build the first mailing list (mailman). Without it mailman won't work.
RUN newlist --urlhost=lists.freedomlayer.org --emailhost=lists.freedomlayer.org \
	mailman some_email@example.com 123456

expose 25 80

cmd ["sh", "-c", "service syslog-ng start ; service postfix start ; /etc/init.d/supervisor start; /usr/lib/mailman/bin/mailmanctl start; tail -F /var/log/mailman/*"]
