# ~/.bash_logout: executed by bash(1) when login shell exits.

# when leaving the console clear the screen to increase privacy

if [ "$SHLVL" = 1 ]; then
# KeithB: `reset` is superior to `clear_console`
#    [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
  if [ -x /usr/bin/tput ]
  then
    /usr/bin/tput reset
  elif [ -x /usr/bin/reset ]
  then
    /usr/bin/reset
  elif [ -x /usr/bin/clear_console ]
  then
    /usr/bin/clear_console -q
  elif [ -x /usr/bin/clear ]
  then
    /usr/bin/clear
  fi
fi

