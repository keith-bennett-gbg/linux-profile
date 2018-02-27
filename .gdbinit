
# Disable Python pretty printers (they are generally broken)
disable pretty-print

# Enable GDB's internal pretty printing (generally just adds whitespace formatting)
set print pretty on

# tl;dr: Ubuntu's GCC package is FUCKING RETARDED
# its pretty printer is fucking broken and causes nightmares
# and is the entire goddamn fucking reason for the two above commands
#
# if this doesn't work, then nuke it from orbit. It's the only way to be sure:
# sudo mv /usr/share/gcc-7/python /usr/share/gcc-7/python-disabled
set auto-load python-scripts off

# Pagination pauses printing when screen is full and asks user if they want to stop or continue. I always want it to print the full output (and I sometimes regret it but I'm okay with that)
set pagination off
