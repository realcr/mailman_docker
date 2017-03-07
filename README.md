# Mailman docker image

This is a Docker based setup for running a
[Mailman](http://www.gnu.org/software/mailman/) server (Of version 2).

Basically it builds a Docker images with Docker, Apache and Postfix over Ubuntu
14.04.
It works out of the box. You don't really need to know anything. It is
persistant (Using a data container with volumes), and has ready to use commands
for backup and restore.

You will need to have docker installed though.

## Having a working server in minutes

### Basic Configuration:
Create your own configuration file from the example template:

	cp example_server.conf server.conf

Edit server.conf. It should contain the mailman list owner email, mailman
list owner password, mailman domain and mailman site password. It also contains
the wanted HTTP port and SMTP port. Those are the only things I couldn't
provide for you :) You will have to fill it in yourself.

server.conf is listed in .gitignore, to make sure that you don't accidently add
them to your repository.

### Building the images:

This is a step you have to do only once:

	sudo ./build_images.sh

This will build the Docker images mailman_server and mailman_data. (Note that
you don't have to redo this step even if you change server.conf. This step is
independent of server.conf)

### Starting the server:

First we create a data container. (You will only do it once. You never need to
do it again, unless you want to initialize all the data of your mailman
server):

	sudo ./initial_data_cont.sh

Next, we start the server:

	sudo ./start_server.sh

You can use your browser now to see the result. Go to the address that you have
specified as MAILMAN_DOMAIN inside server.conf.

To stop the server, you can use the command:
	
	sudo ./stop_server.sh

If you feel like debugging something, open an interactive server sessions with:

	sudo ./inter_server.sh

## Backups

You can backup or restore backups.
Backup is done using the command:

	sudo ./backup_data.sh

This command will create a tar file (His name will be the current date and
time) at the ./backups folder. Note that ./backup_data will not work if the
server is working. You have to stop the server first using the stop_server
command.

Restoring is done using the command:

	sudo ./restore_data.sh <tar_file>

You have to supply some backup tar file for this command to work. This command,
just like backup_data, will not work if the server is working. Make sure to
stop the server first. (If you forget, the restore_data command will remind you
to do so, No worries :) )


## How does it work?

We are working with two Docker images: mailman_server and mailman_data. Both of
them are built using the build_images.sh script. 

The mailman_data image is based on busybox, and is used as a container of
volumes. It contains nothing besides the data required to keep state for the
Mailman server. There are three main folders in mailman that we need to save to be
able to keep state. Those are /var/lib/mailman/{lists,archives,data}. 

The mailman_data_cont container is created based on the mailman_data image.
This container holds the data of the Mailman server.

The second container we create is mailman_server_cont. It is created from the
mailman_server image together with the configuration file server.conf. This
container holds all the installation of Mailman, Apache and Postfix, and the
relevant configuration.

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

