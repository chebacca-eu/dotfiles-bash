#!/bin/bash

# ------------------------------------------------------------------------------
#  Custom configuration file for interactive Bash shells - as used in Manjaro
#  Linux (https://manjaro.org/)
#
#  This file should be saved in your home directory, after which it would be
#  called by adding the following line at the end of your existing ~/.bashrc
#  file:
#      [[ -r ~/.extend.bashrc ]] && . ~/.extend.bashrc
#
#  Author: Chema Barcala (https://github.com/chebacca-eu)
# ------------------------------------------------------------------------------


# If the current shell is not interactive, ignore the rest of this script
[[ "$-" != *i* ]] && return


# --- Terminal -----------------------------------------------------------------

# Disable XON/XOFF flow control
# By default: press CTRL-S to suspend terminal output, and CTRL-Q to resume.
# This would allow, for example, searching history forward in Bash with CTRL-S
stty -ixon


# --- Aliases ------------------------------------------------------------------

alias lsc='ls --color'
alias lsa='lsc -lAh'
