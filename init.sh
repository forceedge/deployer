#!/usr/bin/env bash
# add code to bashrc file so deploy can be used

# check if alias exists, if not add it.

currentDirectory=$(pwd)

if [[ ! -f $currentDirectory/init.sh ]]; then
	echo 'This script needs to run from the project folder, aborting...'
else
	echo 'Checking for deployer installation...'

	if [[ ! -f /usr/bin/deployer ]]; then
		echo 'Sorting out file permissions...'
		chmod -R 0777 ./core

		echo 'Creating symlink...'
		sudo ln -s $currentDirectory/core/loader.sh /usr/bin/deployer

		if [[ ! -f $currentDirectory/config/main.sh ]]; then
			echo 'Setup current project'
			vim $currentDirectory/config/project.sh
		fi
	else
		echo 'Already installed...'
	fi

	echo 'Use the "deployer" command to get started..."'
fi

echo 'Done.'