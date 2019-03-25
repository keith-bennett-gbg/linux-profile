#!/usr/bin/bash

garbage=( /usr/lib/gvfs/gvfs{-{afc,goa,gphoto2,mtp}-volume-monitor,d-{afc,afp,afp-browse,dav,recent,trash,network,dnssd}} /usr/bin/seahorse /usr/bin/gnome-keyring{,-3,-daemon} /usr/lib/bluetooth/bluetoothd /usr/lib/blueman/blueman-mechanism )
garbage=( "$( for g in "${garbage[@]}"; do if [ -x "${g}" ]; then echo -n "${g} "; fi; done )" )
if [ "${#garbage}" -gt 0 ]
then
	echo "~/.bashrc: garbage is executable: ${garbage[@]}"
	exit 1
fi
