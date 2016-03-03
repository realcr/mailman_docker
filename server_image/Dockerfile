# Based on https://github.com/colmsjo/docker/tree/master/containers/mailman
# and some other stuff.

FROM ubuntu:14.04
MAINTAINER real <real@freedomlayer.org>

# run echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list # 2013-08-24

# Install required packages:
RUN \
	apt-get update && \
	apt-get upgrade -qqy \
	DEBIAN_FRONTEND=noninteractive apt-get install -y \
		ntp \
		ntpdate \
		gettext-base \
		moreutils \
		mutt \
		vim \
		dnsutils \
		wget \
		curl \
		language-pack-en \
		apache2 \
		mailman \
		syslog-ng \
		syslog-ng-core \
		postfix \
		supervisor

# Sync the time:
RUN service ntp stop
RUN ntpd -gq
RUN service ntp start


RUN update-locale LANG=en_US.UTF-8

RUN echo mail > /etc/hostname

###############[ Install syslog-ng ]################################

# Use syslog-ng to get Postfix logs (rsyslog uses upstart which does not seem
# to run within Docker).

# Added syslog-ng-core to solve a problem here.
# Advice from: https://bugs.launchpad.net/ubuntu/+source/syslog-ng/+bug/1242173

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

# I have to supply some mailname. It seems like later configuration will 
# override this value, so I just pick something random.
# (MY_DOMAIN_PLACEHOLDER).
RUN echo "postfix postfix/mailname string MY_DOMAIN_PLACEHOLDER" >> preseed.txt

# Use Mailbox format.
RUN debconf-set-selections preseed.txt

