#!/bin/sh

if [ $# -eq 0 ]; then
	echo "Usage: $0 playbook"
	echo "playbook: playbook file (e.g. playbook.yml)"
	exit 1
fi

# -K: ask for sudo password
# -e: supply a variable to the script to let it know we will override the groups
ansible-playbook -K -e 'config_groups=local' "$@"

