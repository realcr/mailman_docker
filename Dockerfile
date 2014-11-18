# Taken from https://github.com/colmsjo/docker/tree/master/containers/mailman

from ubuntu:14.04
maintainer real <real.flayer@outlook.com>

# run echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list # 2013-08-24

run apt-get update
run apt-get install -q -y language-pack-en
run update-locale LANG=en_US.UTF-8

run echo mail > /etc/hostname
add etc-hosts.txt /etc/hosts
run chown root:root /etc/hosts

run apt-get install -q -y vim

# Install Postfix.
run echo "postfix postfix/main_mailer_type string Internet site" > preseed.txt
run echo "postfix postfix/mailname string lists.freedomlayer.ord" >> preseed.txt
# Use Mailbox format.
run debconf-set-selections preseed.txt
run DEBIAN_FRONTEND=noninteractive apt-get install -q -y postfix

run postconf -e myhostname=mail.example.com
run postconf -e mydestination="lists.freedomlayer.org, freedomlayer.org, localhost.localdomain, localhost"
run postconf -e mail_spool_directory="/var/spool/mail/"
run postconf -e mailbox_command=""

# Add a local user to receive mail at someone@example.com, with a delivery directory
# (for the Mailbox format).
run useradd -s /bin/bash someone
run mkdir /var/spool/mail/someone
run chown someone:mail /var/spool/mail/someone

add etc-aliases.txt /etc/aliases
#run chown root:root /etc/aliases
#run rm /etc/aliases.db
#run touch /etc/aliases.db
# run /bin/sh -c "cd /etc; postmap aliases"
#run newaliases

# Use syslog-ng to get Postfix logs (rsyslog uses upstart which does not seem
# to run within Docker).

# Added syslog-ng-core to solve a problem here.
# Advice from: https://bugs.launchpad.net/ubuntu/+source/syslog-ng/+bug/1242173
run apt-get install -q -y syslog-ng syslog-ng-core

# Taken from: https://registry.hub.docker.com/u/dockerbase/syslog-ng/dockerfile/
# Replace the system() source because inside Docker we can't access /proc/kmsg.
# https://groups.google.com/forum/#!topic/docker-user/446yoB0Vx6w
RUN sed -i -E 's/^(\s*)system\(\);/\1unix-stream("\/dev\/log");/' /etc/syslog-ng/syslog-ng.conf
# Uncomment 'SYSLOGNG_OPTS="--no-caps"' to avoid the following warning:
# syslog-ng: Error setting capabilities, capability management disabled; error='Operation not permitted'
# http://serverfault.com/questions/524518/error-setting-capabilities-capability-management-disabled#
RUN sed -i 's/^#\(SYSLOGNG_OPTS="--no-caps"\)/\1/g' /etc/default/syslog-ng


#
# Jonas C.
#

# Good foor debugging
run apt-get -y install mutt vim dnsutils wget curl

# Need to use smarthost when running in docker (since these IP-adresses often are blocked for spam purposes)
# See: http://www.inboxs.com/index.php/linux-os/mail-server/52-configure-postfix-to-use-smart-host-gmail

run echo smtp.gmail.com USERNAME:PASSWORD > /etc/postfix/relay_passwd
run chmod 600 /etc/postfix/relay_passwd
run postmap /etc/postfix/relay_passwd
add etc-postfix-main.cf /etc-postfix-main.cf
run cat /etc-postfix-main.cf >> /etc/postfix/main.cf


#-------------------------------------------------------------------------
# Install apache
#

# Keep upstart from complaining
#RUN dpkg-divert --local --rename --add /sbin/initctl
#RUN ln -s /bin/true /sbin/initctl

#RUN apt-get update


#
# Install supervidord (used to handle processes)
#

RUN apt-get install -y supervisor
ADD ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf


#
# Install Apache


RUN apt-get install -y apache2


#-------------------------------------------------------------------------
# Install mailman
#

#run echo "postfix postfix/mailname string mail.example.com" > preseed.txt
#run debconf-set-selections preseed.txt
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mailman


# Supply our own apache configuration??
# ADD ./mailman.conf /etc/apache2/sites-enabled/mailman

RUN ln -s /etc/mailman/apache.conf /etc/apache2/sites-enabled/mailman
RUN /etc/init.d/apache2 restart

RUN postconf -e 'relay_domains = lists.example.com'
RUN postconf -e 'transport_maps = hash:/etc/postfix/transport'
RUN postconf -e 'mailman_destination_recipient_limit = 1'
RUN postconf -e 'alias_maps = hash:/etc/aliases, hash:/var/lib/mailman/data/aliases'

#In /etc/postfix/master.cf double check that you have the following transport:
#
#mailman   unix  -       n       n       -       -       pipe
#  flags=FR user=list argv=/usr/lib/mailman/bin/postfix-to-mailman.py
#  ${nexthop} ${user}
#
#It calls the postfix-to-mailman.py script when a mail is delivered to a list.
#
#Associate the domain lists.example.com to the mailman transport with the transport map. Edit the file /etc/postfix/transport:
#
#lists.example.com      mailman:

ADD ./etc-mailman-mm_cfg.py /etc/mailman/mm_cfg.py

ADD ./etc-postfix-transport /etc/postfix/transport
RUN chown root:list /etc/postfix/transport

RUN postmap -v /etc/postfix/transport

#RUN chown root:list /var/lib/mailman/data/aliases
RUN chown root:list /etc/aliases

RUN newaliases

expose 25 80
cmd ["sh", "-c", "service syslog-ng start ; service postfix start ; /etc/init.d/supervisor start; /usr/lib/mailman/bin/mailmanctl start; tail -F /var/log/mailman/*"]
