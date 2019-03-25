#!/usr/bin/bash

# List of garbage apps
garbage=(
	# Gnome Virtual Filesystem
	# I absolutely DO NOT want Gnome to run daemons for garbage.
	#
	# That includes shit like:
	# afc: iPhone / iPod Touch
	# afp: Apple Filing Protocol
	# dav: insecure HTTP WebDAV
	# dnssd: DNS Service Discovery
	# ftp: insecure FTP
	# http: insecure HTTP
	# gphoto2: GNU Photo
	# mtd: Media Transfer Protocol
	# nfs: insecure NFS
	# smb: Windows Samba
	# goa: Gnome Online Accounts
	#
	# Extra shitty shit like such:
	# recent: recent://
	# trash: trash://
	# network: network://
	# 
	/usr/lib/gvfs/gvfs-{afc,afp,afp-browse,dav,goa,gphoto2,mtp,smb,smb-browse,recent,trash,network,dnssd}-volume-monitor
	/usr/lib/gvfs/gvfsd-{afc,afp,afp-browse,dav,goa,gphoto2,mtp,smb,smb-browse,recent,trash,network,dnssd}

	# Any sort of credential-caching "agent" whatsoever is an anti-pattern.
	# -> ssh-agent
	# -> seahorse
	# -> gnome-keyring
	/usr/bin/ssh-agent
	/usr/bin/seahorse
	/usr/bin/gnome-keyring{,-3,-daemon}

	# Autostarting bluetooth garbage
	/usr/lib/bluetooth/bluetoothd
	/usr/lib/blueman/blueman-mechanism
)

# Filter list on whether garbage is executable
garbage=( "$(
	for g in "${garbage[@]}"
	do
		if [ -x "${g}" ]
		then
			echo -n "${g} "
		fi
	done
)" )

# If any are, then tell me.
if [ "${#garbage}" -gt 0 ]
then
	>&2 echo "~/.bashrc: garbage is executable: ${garbage[@]}"
	exit 1
fi
