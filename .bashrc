# .bashrc

# Source global definitions
[ -f /etc/bashrc ] && . /etc/bashrc

# Load bash completions
. $HOME/.local/share/bash-completion/bash_completion

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ls='ls --color=auto'

[ -n "$TERM" ] && alias htop='TERM=screen htop'

[ -f "$HOME/.local/bin/nginx-logs.sh" ] && alias nginx-logs='sudo $HOME/.local/bin/nginx-logs.sh'

if [ -f "/bin/firewall-cmd" ] || [ -f "/usr/sbin/csf" ]; then
  deny_ip_add() {
    [ "$1" == "" ] && printf "\033[1;31mYou must specify an IP address to block.\033[0;0m\n" && return 1
    [ -f "/bin/firewall-cmd" ] &&
      /usr/bin/sudo /bin/firewall-cmd --zone="drop" --add-source="$1" &&
      /usr/bin/sudo /bin/firewall-cmd --permanent --zone="drop" --add-source="$1" 1>/dev/null
    [ -f "/usr/sbin/csf" ] &&
      /usr/bin/sudo /usr/sbin/csf -d "$1"
  }
  deny_ip_remove() {
    [ "$1" == "" ] && printf "\033[1;31mYou must specify an IP address to unblock.\033[0;0m\n" && return 1
    [ -f "/bin/firewall-cmd" ] &&
      /usr/bin/sudo /bin/firewall-cmd --zone="drop" --remove-source="$1" &&
      /usr/bin/sudo /bin/firewall-cmd --permanent --zone="drop" --remove-source="$1" 1>/dev/null
    [ -f "/usr/sbin/csf" ] &&
      /usr/bin/sudo /usr/sbin/csf -dr "$1"
  }
  alias firewall-deny=deny_ip_add
  alias firewall-denyr=deny_ip_remove
fi

[ -x "$(which vim)" ] || { >&2 printf "\033[1;31mwarning\033[0;31m: vim not found~\033[0;0m\n"; }
export EDITOR="$(which vim)"
export VISUAL="${EDITOR}"

# Better prompt for shell, but only set if PS1 has already been set (PS1 is not set for non-interactive sessions)
[ -n "$PS1" ] && \
  export PS1="\[$(tput sgr0)\]\[$(tput setaf 1)\][\[$(tput setaf 3)\]\u\[$(tput setaf 2)\]@\[$(tput setaf 4)\]\h\[$(tput setaf 2)\]:\[$(tput setaf 5)\]\w\[$(tput setaf 1)\]]\[$(tput setaf 7)\]\\$ \[$(tput sgr0)\]"

# KeithB: fix Terminal titles with a new prompt
export PROMPT_COMMAND='echo -en "\033]0;$(whoami)@$(hostname):${PWD}\a"'

[ -x /usr/bin/dircolors ] && [ -s ~/.dir_colors ] && eval "$(/usr/bin/dircolors ~/.dir_colors)"

# Shell history settings
export HISTCONTROL=ignoredups:erasedups # no duplicate entries
export HISTSIZE=10000                   # big history
export HISTFILESIZE=10000               # big history
shopt -s histappend                     # append to history, don't overwrite it
shopt -s checkwinsize                   # update LINES and COLUMNS after every command

# Save and reload the history after each command finishes
# export PROMPT_COMMAND="history -a;history -c;history -r;$PROMPT_COMMAND"

# KeithB: default is `ulimit -c 0` -- But I want to always allow core dumps for debugging.
ulimit -c unlimited

# KeithB: GCC colors are beautiful and helpful
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# KeithB: have git print the status of the profile upon login.
# Note: this can break non-interactive sessions (such as scp and sftp), so check PS1
[ ! -z "${PS1}" ] && [ "${PWD}" == "${HOME}" ] && git status

# KeithB: load .profile (local machine profile) if it exists
[ -f "${HOME}/.profile" ] && . "${HOME}/.profile"

# KeithB: .bash_aliases loads stuff from ~/.bash
source ~/.bash_aliases

# KeithB: from `man gpg-agent` to work with PGP smart cards via gpg2
GPG_TTY=$(tty)
export GPG_TTY

unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]
then
	export SSH_AUTH_SOCK="${HOME}/.gnupg/S.gpg-agent.ssh"
fi

