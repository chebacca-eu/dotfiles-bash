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


# --- User-configurable options ------------------------------------------------

declare -A config=(
    # Max number of lines in the history list
    [histSize]=10000
    # Max number of lines in the history file (~/.bash_history)
    [histFileSize]=10000
    # Commands to be ignored by history, separated by colons
    [histIgnore]=''
)


# --- Terminal -----------------------------------------------------------------

# Disable XON/XOFF flow control
# By default: press CTRL-S to suspend terminal output, and CTRL-Q to resume.
# This would allow, for example, searching history forward in Bash with CTRL-S
stty -ixon


# --- Environment variables ----------------------------------------------------


# --- Command history ---

# Append history to the .bash_history file, rather than overwriting it
shopt -s histappend
# Adjust multi-line commands to a single entry, separated by semicolons
shopt -s cmdhist

# History configuration
HISTSIZE=${config[histSize]}
HISTFILESIZE=${config[histFileSize]}
# Do not save lines beginning with a space character, nor those matching the
# preceding entry
HISTCONTROL='ignoreboth'
HISTIGNORE=${config[histIgnore]}
HISTTIMEFORMAT='%F %T  '

# Append every command to the history file as they're introduced, and
# immediately copy this same file's contents to the Bash history. This way,
# commands executed in the current terminal are instantaneously made available
# to any other, and vice versa
PROMPT_COMMAND=$([[ "$PROMPT_COMMAND" ]] && echo "$PROMPT_COMMAND; " || echo '')'history -a; history -c; history -r'


# --- Aliases ------------------------------------------------------------------

alias lsc='ls --color'
alias lsa='lsc -lAh'


# --- Cleanup ------------------------------------------------------------------

unset config
