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

	# Look for keys ending with {.id_ed25519,.id_ecdsa,.id_rsa}
	key=""
	suffices=( id_ed25519 id_ecdsa id_rsa )
	for suffix in "${suffices[@]}"
	do
		# Look for "local_username-local_hostname-remote_username-remote_hostname" (specific) key
		key=$(does_key_exist "$(whoami)-$(hostname)-${username}-${target_host}.${suffix}" )
		[ ! -z "${key}" ] && break

		# Look for "remote_username-remote_hostname" (global generic) key
		key=$(does_key_exist "${username}-${target_host}.${suffix}" )
		[ ! -z "${key}" ] && break

		# Look for "local_username-local_hostname-remote_username-remote_hostname" (instance type) key
		key=$(does_key_exist "$(whoami)-$(hostname)-${username}-$(echo "${target_host}" | sed -r 's/[0-9]+$//g').${suffix}" )
		[ ! -z "${key}" ] && break

		# Look for global LDAP keys "remote_username@search_path" keys
		if [ -f "/etc/resolv.conf" ]
		then
			mapfile -t search_paths < <(grep -P "^\s*search\s+" /etc/resolv.conf | sed -r 's/^\s+//g' | sed -r 's/\s+/\t/g' | cut --complement -f 1)
			if [ "${#search_paths[@]}" -gt 0 ]
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
		>&2 echo "Cannot find, using suffices (\"${suffices[*]}\"), the keyfile for target ${1}: ${username}@${target_host}"
		return 1
	fi

	# Warn if key is deprecated.
	# Ultimately this came down to personal choice.
	#
	# https://security.stackexchange.com/questions/5096/rsa-vs-dsa-for-ssh-authentication-keys/41509#41509
	# https://security.stackexchange.com/questions/50878/ecdsa-vs-ecdh-vs-ed25519-vs-curve25519
	# https://blog.cloudflare.com/ecdsa-the-digital-signature-algorithm-of-a-better-internet/
	# https://latacora.singles/2018/08/03/the-default-openssh.html -- warning about default privkey crypto, says ed25519 isn't vuln
	# https://blog.g3rt.nl/upgrade-your-ssh-keys.html -- DSA and 1024-bit-RSA are definitely deprecated. Talks about ssh-keygen -o -a 100
	#
	# DSA is DO NOT USE
	# RSA < 2048 bit is DO NOT USE
	# RSA = 2048 bit is deprecated (non-deterministic keygen, requires large key length)
	# RSA 4096 bit is fine (personally deprecated)
	# ECDSA is deprecated (breaks if RNG is broken)
	# Ed25519 is fine, but should use `-a` with `ssh-keygen`
	#
	deprecated=( RSA ECDSA )
	for keytype in "${deprecated[@]}"
	do
		ssh-keygen -l -f "${key}" | grep -q "${keytype}"
		CHECK=("${PIPESTATUS[@]}")
		if [[ ${CHECK[0]} -ne 0 ]]
		then
			>&2 echo "Warning: error checking key type for deprecation."
		elif [[ ${CHECK[1]} -eq 0 ]]
		then
			>&2 echo "Warning: using deprecated key type ${keytype}"
		fi
	done

	>&2 echo ssh -i "${key}" "${username}@${target_host}" "${@:2}"
	ssh -i "${key}" "${username}@${target_host}" "${@:2}"
}

