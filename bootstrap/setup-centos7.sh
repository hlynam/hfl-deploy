#!/bin/sh

# Error if variable is unassigned
set -u


# Add user to sudo
function add_user_to_sudo() {
	echo
	echo "*** Adding user to sudo"
	echo
	sudo ls /etc >/dev/null
	ret=$?
	if [ $ret -eq 0 ]; then
		echo "Already in sudo"
		return 0
	fi

	echo "Adding user to sudo..."
	su -c "gpasswd -a $USER wheel"

	# https://superuser.com/questions/272061/reload-a-linux-users-group-assignments-without-logging-out
	echo "Restart required..."
	prompt_continue 'Do you want to continue?'
	shutdown -r now
	exit 0
}

# Prompt to continue
# http://stackoverflow.com/questions/3231804/in-bash-how-to-add-are-you-sure-y-n-to-any-command-or-alias
function prompt_continue() {
	msg="$1 [y/N]"
	response=''
	read -r -p "$msg " response
	case "$response" in
		[yY][eE][sS]|[yY]) 
			;;
		*)
			exit 1
			;;
	esac
}

# Turn off automatic updates
function turn_off_automatic_updates() {
	echo
	echo "*** Turning off automatic updates"
	echo
	automaticUpdates=$(gsettings get org.gnome.software download-updates)
	if [[ "$automaticUpdates" =~ false ]]; then
		echo "Automatic updates are off"
		return 0
	fi

	echo "Turning off automatic updates"

	gsettings set org.gnome.software download-updates false
	echo "Restart required..."
	prompt_continue 'Do you want to continue?'
	shutdown -r now
	exit 0
}

# Install EPEL repository
function install_epel_repo() {
	echo
	echo '*** Installing EPEL repo'
	echo
	sudo yum install epel-release
}

# Install Ansible
function install_ansible() {
	echo
	echo '*** Installing ansible'
	echo
	sudo yum install ansible
}

# Check Ansible
function check_ansible() {
	echo
	echo '*** Ansible version'
	echo
	ansible --version
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "There is a problem running ansible ($ret)"
		exit $ret
	fi
}

add_user_to_sudo
turn_off_automatic_updates
install_epel_repo
install_ansible
check_ansible

