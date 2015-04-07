#!/usr/bin/env bash

function deployer_init() {
	perform 'Create deployer.config file for current project'
	if [[ -f ./deployer.config ]]; then
		warning "deployer.config already exists, run 'deployer config:edit' to edit this file'"
	else
		cp "$DEPLOYER_LOCATION/template/main.sh.dist" ./deployer.config
		performed
	fi

	perform 'Initialize git repo (safe)'
	git init &>/dev/null
	performed
	perform "Set push configuration to 'current'"
	git config --global push.default current
	performed
	info 'Please configure the deployer.config file in order to use deployer'
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

function deployer_local_update() {
	cd $localProjectLocation && git pull origin
}

function deployer_local_edit_project() {
	if [[ -z "$editor" ]]; then
		warning 'Editor not configured, using vim'
		editor='vim'
	fi

	$editor $localProjectLocation
}

function Deployer_version() {
	cd $DEPLOYER_LOCATION && git status | head -n 1
	blue 'Deployer installation folder: '
	echo -n $DEPLOYER_LOCATION
}

function Deployer_config_edit {
	attempt 'edit project config file'
	$editor $localProjectLocation/deployer.config
}

function Deployer_update() {
	warning 'Updating deployer'
	cd $DEPLOYER_LOCATION && git pull origin && git pull origin --tags
}

function Deployer_local_run() {
	if [[ -z "$1" ]]; then
		return 
	fi
	warning 'Running command on local project'
	cd $localProjectLocation
	$1
}

function deployer_dev() {
	if [[ -z $devStart ]]; then
		warning 'Nothing todo...'
	fi
	
	perform 
	performed "$devStart"
	cd $localProjectLocation
	$devStart
}

function Deployer_project_save() {
	cd $localProjectLocation
	attempt 'save project'
	changes=$(git status -s)
	if [[ -z $changes ]]; then
		warning 'No changes detected'
		unpushed=$(git log --branches --not --remotes --simplify-by-decoration --decorate --oneline --abbrev-commit)
		result=$?
		if [[ ! -z $unpushed ]]; then
			info 'Unpushed Commit(s)'
			git log --branches --not --remotes --simplify-by-decoration --decorate --oneline --abbrev-commit
			printForRead 'You have unpushed commits, would you like to push them? [Y/N]: '
			if [[ $(userChoice) == 'Y' ]]; then
				echo
				perform 'Push local changes'
				git push
				result=$?
			fi
			echo
		fi
		if [[ $result != 0 ]]; then
			error 'There was an error, please review and re-run this command'
			return
		fi

		printForRead 'deploy current branch? [Y/N]: '
		if [[ $(userChoice) != 'Y' ]]; then
			return
		fi
		echo
		currentBranch=$(git rev-parse --abbrev-ref HEAD)
		deployer_deploy $currentBranch

		return
	fi
    perform 'Add all files for commit'
	git add --all
	performed
	perform 'Show branch/files'
	git status -sb
	readUser 'Please enter commit message: '
    git commit -m "$input"
	perform 'Push changes'
	branch=$(getCurrentBranchName)
	output=$(git push origin $branch)
	if [[ $(echo $?) != 0 ]]; then
		error 'Unable to push, aborting...'
		return
	fi
	performed
	currentBranch=$(git rev-parse --abbrev-ref HEAD)
	deployer_deploy $currentBranch
}