#!/usr/bin/env bash

function deployer_select_project() {
	warning 'Select a project'
	Deployer_local_run
	cat -n $projectsLog
	readUser 'Enter project number: '

	project=$(awk "NR==$input" $projectsLog)

	if [[ -z $project ]]; then
		error "Could not find project number $input"

		return
	fi

	if [[ ! -d $project ]]; then
		error 'Project not found!'
		perform 'Remove entry from projects file'
		sed -i'.bk' -e "$input"d "$projectsLog"
		performed

		return
	fi

	cd "$project"
	deployer_use
	info 'Project set to: '$project
}

function Deployer_project_save() {
	cd $localProjectLocation
	attempt 'save project'
	branch=$(getCurrentBranchName)

	if [[ $allowSaveToMaster == false && $branch == 'master' ]]; then
		error 'allowSaveToMaster is set to false, cannot push to master. Please create another branch and save again'

		return
	fi
	
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
	output=$(git push origin $branch)
	if [[ $(echo $?) != 0 ]]; then
		error 'Unable to push, aborting...'
		return
	fi
	performed

	if [[ -z $sshServer ]]; then
		warning 'sshServer not set, will not deploy'
		return
	fi

	currentBranch=$(git rev-parse --abbrev-ref HEAD)
	deployer_deploy $currentBranch
}

function Deployer_project_diff() {
	warning "showing diff on project"
	cd $localProjectLocation
	git diff $1
}

function Deployer_project_status() {
	warning "Show status of project"
	cd $localProjectLocation
	git status
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

function Deployer_local_run() {
	if [[ -z "$1" ]]; then
		# load libs
		if [[ -z $localProjectLocation ]]; then
			warning "Project Location ------> Please set project location to use deployer"
		else
			info "Project Location ------> $localProjectLocation"
		fi

		return 
	fi
	warning 'Running command on local project'
	cd $localProjectLocation
	"$1"
}

function deployer_open_web() {
	if [[ ! -z "$webURL" ]]; then 
		open $webURL
	else 
		error "Value for 'webURL' not specified in config" 
	fi
}