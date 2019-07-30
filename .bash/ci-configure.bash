#!/usr/bin/env bash
#
# This file is designed to read the .env file (which is for docker-compose) and
# use it as a template to for the same variables injected by a Continuous
# Integration service such as TeamCity, Jenkins, or etc.
#
# This script will then write a new .env file. The new .env file will be
# appropriate for running `docker-compose up` so that the application will
# inherit the values provided by CI instead of the defaults from the git
# repository.
#
# That means that the .env file _must_ be clean before running this script,
# otherwise you may have data left over from a previous CI run. This version of
# the script will use git to check for cleanliness. If you use an inferior CI
# then you'll need to change this. In particular, it will print a diff if the
# local .env file is dirty.
#
# I know we have a lot of bash newbies here and you're likely looking at this
# to learn or debug. Check these resources out.
# http://www.shellcheck.net/
# https://unix.stackexchange.com/a/122848/128494

# -e: stop on errors
# -u: use of undefined variables is an error
# -o pipefail: any process, not just the last, can cause the pipeline to fail
# Google these if you don't understand what they do.
set -euo pipefail

# You can optionally specify an alternate .env file.
ENV_FILE=${1:-./.env}


# If ./.env isn't clean, then show the differences and exit.
git diff --exit-code "${ENV_FILE}" || {
	>&2 echo "${ENV_FILE} is not clean; refusing to overwrite unsaved changes."
	exit 1
}

# Grab environment variable names and assign them to ENV_KEYS array.
mapfile -t ENV_KEYS < <(
	< "${ENV_FILE}" \
		grep -vP "^#|^\s*$" \
	| cut -d '=' -f 1
)

# If any ENV_KEYS has certain characters, then it will likely cause trouble
# later so let's just say it's malformed.
for n in "${!ENV_KEYS[@]}"
do
	# https://stackoverflow.com/a/24231346/1111557
	#
	# only valid variables are defined to follow the pattern:
	# any letter or underscore, followed by any digit, letter, or underscore
	if echo -n "${ENV_KEYS[${n}]}" | grep -vqP '^[A-Za-z_][\dA-Za-z_]*$'
	then
		>&2 echo "${ENV_FILE} file contains a malformed entry: ${ENV_KEYS[${n}]}"
		exit 1
	fi
done

defaulted() {
	# Single line values only. Same as how docker-compose works.
	< "${ENV_FILE}" grep -P "^$1=" | sed -r "s/^$1=//"
}

# Look for CI-specified environment variables. If not specified, populate with
# the .env default. CI is permitted to specify it empty!
set +u
for n in "${!ENV_KEYS[@]}"
do
	KEY="${ENV_KEYS[${n}]}"
	if [ -z "${!KEY}" ]
	then
		export "${ENV_KEYS[${n}]}"="$(defaulted "${ENV_KEYS[${n}]}")"
	fi
done
set -u

# Print everything to .env, tee for the logs.
# Remember, YOUR SECRETS DO NOT BELONG IN ENVIRONMENT VARIABLES DESPITE WHAT
# MANY SOURCES MIGHT TELL YOU.
for n in "${!ENV_KEYS[@]}"
do
	echo "${ENV_KEYS[${n}]}"="${!ENV_KEYS[${n}]}"
done |
tee > "${ENV_FILE}"
