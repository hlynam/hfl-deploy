#!/bin/sh

if [ $# -eq 0 ]; then
	echo "Usage: $0 playbook"
	echo "playbook: playbook file (e.g. playbook.yml)"
	exit 1
fi

ansible-playbook --inventory "localhost," --connection local "$@"

