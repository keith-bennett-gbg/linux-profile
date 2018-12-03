#!/usr/bin/env bash

function is-reboot-required {
	if [[ -f /var/run/reboot-required ]]
	then
		echo "/var/run/reboot-required: yes"
	else
		echo "/var/run/reboot-required: no"
	fi
}

function reboot-required {
	is-reboot-required
}

function is_reboot_required {
	is-reboot-required
}

function reboot_required {
	is-reboot-required
}

