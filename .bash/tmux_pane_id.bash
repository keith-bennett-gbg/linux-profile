
function tmux_pane_id() {
	[[ -x $(which tmux) ]] || { return; }
	TMUX_PANE_ID=$(tmux display -pt "${TMUX_PANE:?}" '#{pane_index}')
}

