# Mailman docker image

This is a Docker based setup for running a
[Mailman](http://www.gnu.org/software/mailman/) server.

Basically it builds a Docker images with Docker, Apache and Postfix over Ubuntu
14.04.
It works out of the box. You don't really need to know anything. It is
persistant (Using a data container with volumes), and has ready to use commands
for backup and restore.

You will need to have docker installed though.

## Having a working server in minutes

### Basic Configuration:
Create your own configuration files from the example template:

	cp example_ports.conf ports.conf
	cp server_images/example_server.conf server_images/server.conf

Next edit ports.conf to have the ports you want. (The defaults in
example_server.conf are 80 for HTTP and 25 for SMTP).

Then edit server.conf. It should contain the mailman list owner email, mailman
list owner password, mailman domain and mailman site password. Those are the
only things I couldn't provide for you :) You will have to fill it in yourself.

server.conf and ports.conf are listed in .gitignore, to make sure that you
don't accidently add them to your repository.

### Building the images:

This is a step you have to do only once:

	sudo ./build_images

This will build the Docker images mailman_server and mailman_data.

### Starting the server:

First we create a data container. (You will only do it once. You never need to
do it again, unless you want to initialize all the data of your mailman
server):

	sudo ./initial_data_cont

Next, we start the server:

	sudo ./start_server

You can use your browser now to see the result. Go to the address that you have
specified as MAILMAN_DOMAIN inside server.conf.

To stop the server, you can use the command:
	
	sudo ./stop_server

## Backups

You can backup or restore backups.
Backup is done using the command:

	sudo ./backup_data

This command will create a tar file (His name will be the current date and
time) at the ./backups folder. Note that ./backup_data will not work if the
server is working. You have to stop the server first using the stop_server
command.

Restoring is done using the command:

	sudo ./restore_data <tar_file>

You have to supply some backup tar file for this command to work. This command,
just like backup_data, will not work if the server is working. Make sure to
stop the server first. (If you forget, the restore_data command will remind you
to do so, No worries :) )


## How does it work?

We are working with two Docker images: mailman_server and mailman_data. Both of
them are built using the build_images.sh script. mailman_server image is built
using the configuration inside ./server_image/server.conf, therefore if you
make any changes to this configuration file you should rebuild the images.

The mailman_data image is based on busybox, and is used as a container of
volumes. It contains nothing besides the data required to keep state for the
Mailman server. There are three main folders in mailman that we need to save to be
able to keep state. Those are /var/lib/mailman/{lists,archives,data}. 

The mailman_data_cont container is created based on the mailman_data image.
This container holds the data of the Mailman server.

The second container we create is mailman_server_cont. It is created from the
mailman_server image. This container holds all the installation of Mailman,
Apache and Postfix. Being derived from mailman_server, it also contains all the
configuration from ./server_image/sersver.conf.

The mailman_server_cont uses the volumes from the mailman_data_cont. This is
how we keep the state of the Mailman server.

## Known issues:

If instead of using the domain name I use the IP address when accessing the
generated website, the default Apache page is presented. If you disable the
default service (Using ap2dissite 000-default), you will get a mailman page for
a domain which is the IP (Definitely not what you want). See my SO question
here for more details:

http://serverfault.com/questions/646456/mailman-and-apache-virtual-hosts-problems

## Final notes:
It took about a week to make this work. I'm pretty happy with the result,
though I'm pretty sure there is some place for improvement. If you have any
thoughts or ideas to improve it, feel free to send them here.

