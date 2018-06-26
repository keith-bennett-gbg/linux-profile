#!/bin/bash

function does_key_exist()
{
	[ $# -eq 0 ] && return
	if [ -f "${HOME}/.ssh/${1}" ]
	then
		echo -n "${HOME}/.ssh/${1}"
	fi
}

sshi() {
	if [ $# -eq 0 ]
	then	
		ssh
		return $?
	fi

	username=$(echo -n "${1}" | grep -oP "^.*@")
	if [ "${username}" == "" ]
	then
		username=$(whoami)
	else
		# remove @
		username=${username:0:${#username}-1}
		if [ "${username}" == "" ]
		then
			username=$(whoami)
		fi
	fi

	target_host=$(echo -n "${1}" | grep -oP "@.*$")
	if [ "${target_host}" == "@" ]
	then
		target_host=$(hostname)
	elif [ "${target_host:0:1}" == "@" ]
	then
		# remove @
		target_host="${target_host:1}"
	elif [ "${target_host}" == "" ]
	then
		target_host="${1}"
	fi

	# Look for keys ending with {.id_rsa,.id_ecdsa}
	key=""
	suffices=( id_rsa id_ecdsa )
	for suffix in ${suffices[@]}
	do
		# Look for "local_username-local_hostname-remote_username-remote_hostname" (specific) key
		key=$(does_key_exist "$(whoami)-$(hostname)-${username}-${target_host}.${suffix}" )
		[ ! -z "${key}" ] && break

		# Look for "remote_username-remote_hostname" (global generic) key
		key=$(does_key_exist "${username}-${target_host}.${suffix}" )
		[ ! -z "${key}" ] && break

		# Look for "local_username-local_hostname-remote_username-remote_hostname" (instance type) key
		key=$(does_key_exist "$(whoami)-$(hostname)-${username}-$(echo ${target_host} | sed -r 's/[0-9]+$//g').${suffix}" )
		[ ! -z "${key}" ] && break

		# Look for global LDAP keys "remote_username@search_path" keys
		if [ -f "/etc/resolv.conf" ]
		then
			search_paths=( $(grep -P "^\s*search\s+" /etc/resolv.conf | sed -r 's/^\s+//g' | sed -r 's/\s+/\t/g' | cut --complement -f 1) )
			if [ ! -z "${search_paths}" ]
			then
				for search_path in "${search_paths[@]}"
				do
					key=$(does_key_exist "${username}@${search_path}.${suffix}" )
					[ ! -z "${key}" ] && break
				done
			fi
		fi
		[ ! -z "${key}" ] && break
	done
	if [ -z "${key}" ]
	then
		>&2 echo "Cannot find, using suffices ${suffices[@]}, the keyfile for target ${1}: ${username}@${target_host}"
		return 1
	fi

	>&2 echo ssh -i "${key}" "${username}@${target_host}" "${@:2}"
	ssh -i "${key}" "${username}@${target_host}" "${@:2}"
}

