# Based on https://github.com/colmsjo/docker/tree/master/containers/mailman
# and some other stuff.

FROM ubuntu:14.04
MAINTAINER real <real.flayer@outlook.com>

# run echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list # 2013-08-24

RUN apt-get update
RUN apt-get upgrade -qqy

# Get ntp stuff for time syncing:
RUN apt-get install -q -y ntp ntpdate
# Sync the time:
RUN service ntp stop
RUN ntpd -gq
RUN service ntp start

# Used to get the envsubst command 
# (Replaces environment variables by their value in configuration files.)
# See for example:
# http://stackoverflow.com/questions/14155596/how-to-substitute-shell-variables-in-complex-text-files
# moreutils is used for the sponge bash command.
RUN apt-get -y install gettext-base moreutils

# Good foor debugging
RUN apt-get -y install mutt vim dnsutils wget curl

# Language stuff:
RUN apt-get install -q -y language-pack-en
RUN update-locale LANG=en_US.UTF-8

RUN echo mail > /etc/hostname


# Install Apache2 web server:
RUN apt-get install -y apache2

######################## [Install mailman] ########################

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mailman

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
RUN echo "postfix postfix/mailname string MY_DOMAIN_PLACEHOLDER" >> preseed.txt

# Use Mailbox format.
RUN debconf-set-selections preseed.txt
RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y postfix


######### [Install supervidord] ################## 
# (used to handle processes)

RUN apt-get install -y supervisor

