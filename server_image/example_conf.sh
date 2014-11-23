# Copy this file to conf.sh
# Then fill in your credentials.
# WARNING: Be careful not to upload your conf.sh 
# (Filled with your credentials) to a public repository.

# Required Environment variables for the construction of the
# Mailman docker image.

# The mail address of the owner of mailman list:
export MAILMAN_LIST_OWNER_MAIL=real.flayer@outlook.com

# Mailman's list owner password:
export MAILMAN_LIST_OWNER_PASS=123456

# Domain address for mailman:
export MAILMAN_DOMAIN=lists.freedomlayer.org

# Site password (The highest password for Web authentication):
export MAILMAN_SITE_PASS=12345678
