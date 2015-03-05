#!/usr/bin/env bash

# define cases in this file and run them
case "$1" in 
	'use' )
		deployer_use;;
	'init' )
		deployer_init;;
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
				deployer_remote_init;;
			'reclone' )
				deployer_reclone;;
			'update' )
				deployer_remote_update;;
			'tags' )
				deployer_remote_tags;;
			'status' )
				deployer_remote_status;;
			'services' )
				case "$3" in 
					'start' )
						deployer_services_start;;
					* )
						deployer_services_status;;
				esac;;
			'service' )
				case "$3" in
					'start' )
						deployer_service_perform 'start' "$4";;
					'stop' )
						deployer_service_perform 'stop' "$4";;
					'restart' )
						deployer_service_perform 'restart' "$4";;
					'status' )
						deployer_service_perform 'stop' "$4";;
				esac;;
			* )
				depolyer_remote_project_status;;
		esac;;
	'config' )
		case "$2" in 
			"edit" )
				vim $localProjectLocation/deployer.config;;
			* )
				echo 'Displaying project file...'; 
				cat $localProjectLocation/deployer.config;
				echo '';;
		esac;;
	'update' )
		cd $DEPLOYER_LOCATION; git pull origin master;;
	'open' | 'web' )
		deployer_open_web;;
	'uninstall' )
		deployer_uninstall;;
	'version' | 'v' )
		cd $DEPLOYER_LOCATION; git describe --tag;;
	'test' )
		alterConfigFiles;;
	'project' )
		;;
	*)
		helperMenu;;
esac
# inject linespace
echo ''