# A container that holds data for mailman.

FROM busybox
MAINTAINER real <real@freedomlayer.org>

# Keep mailman's data in a volume, to keep the mailing lists state:
VOLUME ["/var/lib/mailman/data","/var/lib/mailman/lists","/var/lib/mailman/archives"]

