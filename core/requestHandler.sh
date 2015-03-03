#!/usr/bin/env bash

function getDeployerLocation() {
	fileLocation=$(ls -la /usr/bin | grep 'deployer ->' | awk '{split($0, location,/ -> /); print location[2]}')
	export DEPLOYER_LOCATION=$(dirname ${fileLocation})
}

getDeployerLocation

source $DEPLOYER_LOCATION/deploy.sh
source $DEPLOYER_LOCATION/uninstall.sh
source $DEPLOYER_LOCATION/menu.sh
echo "Project Location ------> $localProjectLocation"

# define cases in this file and run them
currentDir=$(pwd)
case "$1" in 
	'ssh' )
		deployer_ssher "$2";;
	'sshp' )
		deployer_ssher_toDir "$2";; 
	'deploy' | 'd' )
		case "$2" in 
			'latest' )
				deployer_deploy_latest;;
			* )
				deployer_deploy "$2";;
		esac;;
	'remote' | 'r' )
		case "$2" in
			'init' | "clone" )
				deployer_init;;
			'reclone' )
				deployer_reclone;;
			'update' )
				deployer_remote_update;;
			'tags' )
				deployer_remote_tags;;
			'status' )
				deployer_remote_status;;
			* )
				depolyer_remote_project_status;;
		esac;;
	'config' )
		case "$2" in 
			"edit" )
				vim $DEPLOYER_LOCATION/../config;;
			* )
				echo 'Displaying config file...'; cat $DEPLOYER_LOCATION/../config/main.sh; echo '';;
		esac;;
	'update' )
		cd $DEPLOYER_LOCATION; git pull origin master;;
	'open' | 'web' )
		open $web;;
	'uninstall' )
		deployer_uninstall;;
	'version' | 'v' )
		cd $DEPLOYER_LOCATION; git describe --tag;;
	*)
		helperMenu;;
esac
# inject linespace
echo ''
cd $currentDir