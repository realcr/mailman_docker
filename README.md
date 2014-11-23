# Mailman docker image

This is a Docker based setup for running a
[Mailman](http://www.gnu.org/software/mailman/) server.

Basically it builds a Docker images with Docker, Apache and Postfix.
It works out of the box. You don't really need to know anything. It is
persistant (Using a data container with volumes), and has ready to use commands
for backup and restore.

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


