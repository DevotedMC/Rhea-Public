#!/usr/bin/env bash

function showCivAnsibleHelp() {
	echo "Invocations of this script must provide a valid set of actions to complete. Actions will be executed in the order they are provided. Valid actions are:"
	echo ""
	echo "deploy           # Will do an initial deployment of the setup, creating databases, database users, folder structures etc."
	echo "update           # Updates all plugin jars and configurations in the deployed setup"
	echo "pull             # Pulls from the master branch of the git repository configured as origin"
	echo "warn10           # Announces an upcoming restart to the server in 10 minutes in increments and blocks until that time span has elapsed"
	echo "warn5            # Announces an upcoming restart to the server in 5 minutes in increments and blocks until that time span has elapsed"
	echo "warn1            # Announces an upcoming restart to the server in 1 minute in increments and blocks until that time span has elapsed"
	echo "backup           # Creates full backup of the map, plugin configs and mysql database in the deployed setup"
	echo "stopmcall        # Stops all Minecraft servers"
	echo "stopmc:<server>  # Stops a specific Minecraft server"
	echo "stopbungee       # Stops BungeeCord"
	echo "stop             # Stops all minecraft server and then BungeeCord"
	echo "startmcall       # Starts all minecraft server"
	echo "startbungee      # Starts BungeeCord"
	echo "start            # Starts BungeeCord and then all minecraft servers"
	echo "duplicity        # Culls backups and syncs them with a remote FTP location"
	echo "help             # Shows this list of commands"
}

if test "$#" -lt 1; then
	echo "You need to provide an action"
	showCivAnsibleHelp
	exit 1
fi

#Iterate over all provided arguments
for var in "$@"
do
	#Force into lower case
    case "${var,,}" in
    	deploy)
			echo "Deploying a full server setup including databases"
			if [[ $EUID -ne 0 ]]; then
   				echo "Initial deployment requires root/sudo, please rerun the script as such" 
  				exit 1
			fi
			ansible-playbook server.yml --extra-vars '{"do_deploy":"true"}'
			ansible-playbook server.yml --extra-vars '{"do_update":"true"}'
			;;
		update)
			echo "Updating all plugins and configurations"
			ansible-playbook server.yml --extra-vars '{"do_update":"true"}'
			;;
		pull)
			echo "Pulling latest from git"
			#Not using git pull here to handle errors a bit more gracefully
			git fetch origin
			git merge origin/master
			;;
		warn10)
			echo "Announcing a restart in 10 minutes to the server"
			ansible-playbook server.yml --extra-vars '{"do_warn10":"true"}'
			;;
		warn5)
			echo "Announcing a restart in 5 minutes to the server"
			ansible-playbook server.yml --extra-vars '{"do_warn5":"true"}'
			;;
		warn1)
			echo "Announcing a restart in 1 minute to the server"
			ansible-playbook server.yml --extra-vars '{"do_warn1":"true"}'
			;;
		backup)
			echo "Creating a backup of the current minecraft map, configs and database"
			ansible-playbook server.yml --extra-vars '{"do_backup":"true"}'
			;;
		stopminecraft)
			echo "Stopping Minecraft"
			ansible-playbook server.yml --extra-vars '{"do_stopminecraft":"true"}'
			;;
		stopbungee)
			echo "Stopping Bungee"
			ansible-playbook server.yml --extra-vars '{"do_stopbungee":"true"}'
			;;
		stop)
			echo "Stopping Bungee and Minecraft"
			ansible-playbook server.yml --extra-vars '{"do_stopbungee":"true", "do_stopminecraft":"true"}'
			;;
		startminecraft)
			echo "Starting Minecraft"
			ansible-playbook server.yml --extra-vars '{"do_startminecraft":"true"}'
			;;
		startbungee)
			echo "Starting Bungee"
			ansible-playbook server.yml --extra-vars '{"do_startbungee":"true"}'
			;;
		start)
			echo "Starting Bungee and Minecraft"
			ansible-playbook server.yml --extra-vars '{"do_startbungee":"true", "do_startminecraft":"true"}'
			;;
		duplicity)
			echo "Applying culling and duplicity to backups"
			ansible-playbook server.yml --extra-vars '{"do_duplicity":"true"}'
			;;
		help)
			echo "Printing help:"
			showCivAnsibleHelp
			;;
		*)
			echo -e "\e[31mThe action '$var' could not be recognized, aborting execution\e[0m"
			echo ""
			showCivAnsibleHelp
			exit 1
    esac
done

