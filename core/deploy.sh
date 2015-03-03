#!/usr/bin/env bash
# create the script to be called by the alias i suppose

function deployer_deploy() {
	if [[ -z "$1" ]]; then
		attempt "pull the latest from master branch"
		perform "pull latest master branch"
		deployer_ssher_toDir "git checkout master; git pull origin master"
		performed
	else
		deployer_remote_update
		perform "Checkout tag '$1'"
		deployer_ssher_toDir "git fetch --tags; git checkout $1"
		performed
	fi
	depolyer_remote_project_status
}

function deployer_init() {
	if [[ -f ./deployer.config ]]; then
		error "deployer.config already exists, run 'deployer config edit' to edit this file'"
	else
		perform 'Create deployer.config file for current project'
		cp "$DEPLOYER_LOCATION/template/main.sh.dist" ./deployer.config
		performed
		info 'Please configure the deployer.config file in order to use deployer'
	fi
}

function deployer_use() {
	attempt "set current directory as project dir"
	perform "locate 'deployer.config' file"
	if [[ ! -f ./deployer.config ]]; then
		error "Unable to locate 'deployer.config' file in current directory, run 'deployer init' to create one."
		return 1
	fi
	performed
	perform 'check if project.sh file exists for deployer'
	if [[ -f $DEPLOYER_LOCATION/../config/project.sh ]]; then
		performed
	else
		performed 'not found, creating...'
		perform 'create project.sh for deployer'
		sudo touch $DEPLOYER_LOCATION/../config/project.sh
		if [[ $? == 0 ]]; then
			performed
		else
			error 'unable to create project.sh file, please resort to manual creation of file'
			return
		fi
	fi
	perform 'set current project dir as deployer current project'
	currentDir=$(pwd)
	echo "#!/usr/bin/env bash
readonly localProjectLocation='$currentDir'" > "$DEPLOYER_LOCATION/../config/project.sh"
	performed
}

function deployer_remote_init() {
	attempt "setup project"
	perform "Clone repo on remote server"
	deployer_ssher_toDir "mkdir -p $remoteProjectLocation; git clone $repo $remoteProjectLocation; cd $remoteProjectLocation/; git remote add origin $repo"
	performed
}

function deployer_reclone() {
	attempt "re-setup project"
	perform "Re-clone repo on remote server"
	deployer_ssher_toDir "rm -rf $remoteProjectLocation; mkdir -p $remoteProjectLocation; git clone $repo $remoteProjectLocation; cd $remoteProjectLocation/; git remote add origin $repo"
	performed
}

function deployer_remote_update() {
	attempt "update"
	perform "Updating remote server"
	deployer_ssher_toDir "git fetch; git fetch origin --tags"
	performed
}

function deployer_remote_tags() {
	attempt "fetch tags from remote machine"
	perform "fetch tags"
	deployer_ssher_toDir "git fetch --tags; git tag"
	performed
}

function deployer_deploy_latest() {
	attempt "Deploy latest tag"
	perform "Fetch latest tag"
	cd $localProjectLocation
	latestTag=$(git fetch; git describe --tags `git rev-list --tags --max-count=1`)

	if [[ -z $latestTag ]]; then
		failed "No tag available"
		return 0
	fi

	performed "$latestTag"
	deployer_remote_update
	perform "Deploy tag $latestTag"
	deployer_ssher_toDir "git checkout $latestTag"
	performed
}

function deployer_remote_status() {
	perform "Ram status"
	echo ''
	deployer_ssher "free -m"
	echo ''
	perform "apache status"
	deployer_ssher "sudo service httpd status"
	echo ''
	perform "mysql status"
	deployer_ssher "sudo service mysqld status"
	echo ''
	depolyer_remote_project_status
}

function depolyer_remote_project_status() {
	perform "remote project version"
	deployer_ssher "cd $remoteProjectLocation; git describe"
}