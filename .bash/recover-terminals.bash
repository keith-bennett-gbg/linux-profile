
function recover_terminals() {
	for session in $(tmux list-sessions | grep -v "(attached)" | cut -d ':' -f 1)
	do
		# gnome-terminal -x tmux attach -t "${session}"
		# Above will say:
		# Error constructing proxy for org.gnome.Terminal:/org/gnome/Terminal/Factory0: Could not connect: Connection refused
		# Workaround found here:
		# https://ubuntuforums.org/showthread.php?t=2362930
		# Relay through dbus-launch.
		dbus-launch gnome-terminal -x tmux attach -t "${session}"
	done
}

