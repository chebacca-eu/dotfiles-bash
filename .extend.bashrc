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

    # Prompt type
    [psType]='handy'    # One of: 'handy' | 'simple' | 'minimal' | 'reset' (default)
    # Prompt color in 256-, 16- and 8-color terminals (only applicable for
    # 'handy' prompt type)
    # Color chart:
    #     https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
    [psColor256]=118    # Color number: 0-255
    [psColor16]=10      # Color number: 0-15
    [psColor8]=2        # Color number: 0-7

    # Favorite text editor
    [editor]='vim'    # Executable name (e.g. 'vim')
)

# Prompt can be changed at any time by calling the function 'setPrompt' with an
# optional parameter, the prompt type, which can be one of the following:
#     'handy' | 'simple' | 'minimal' | 'reset' (default)
#
# For example, to reset the prompt to the existing one before this script is
# executed, you would call:
#     setPrompt reset
# or simply:
#     setPrompt


# ------------------------------------------------------------------------------


# Temporary auxiliary variable
declare -A temp


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


# --- Prompt ---

# Set primary and secondary prompts
#
# Parameters:
#     - 1 (optional): Prompt type. One of:
#         'handy' | 'simple' | 'minimal' | 'reset' (default)
setPrompt () {
    # Previous prompts (before being modified by this script)
    if [[ ! -v PS1_PREV ]]; then    # Check if a variable is not set (works in Bash 4.2+)
#   if [[ -z ${PS1_PREV+set} ]]; then    # Another way (works in older versions of Bash); seen at:
                                         #     http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02
        PS1_PREV=$PS1
        PS2_PREV=$PS2
    fi

    local type=$([[ $# -gt 0 ]] && echo $1 || echo 'reset')

    case "$type" in
        'handy')
            # We use the variable PS_COLOR to remember the prompt color if the
            # type is changed to one which does not use it
            if [[ ! -v PS_COLOR ]]; then
                setPsColor
            fi
            PS1="\$(printNl)\[$PS_COLOR\]\u@\h: \w\n\\$\[$(tput sgr0)\] "
            PS2="\[$PS_COLOR\]>\[$(tput sgr0)\] "
            ;;
        'simple')
            PS1='\u@\h:\w\$ '
            PS2='> '
            ;;
        'minimal')
            PS1='\$ '
            PS2='> '
            ;;
        *)
            PS1=$PS1_PREV
            PS2=$PS2_PREV
            ;;
    esac
}

# Set the PS_COLOR variable (which corresponds to the prompt color) according
# to the number of colors available
setPsColor () {
    # Number of available colors (fallback to 8)
    local -i numColors=$(tput colors 2>/dev/null || echo 8)

    local -i psColor
    if [[ $numColors -ge 256 ]]; then
        psColor=${config[psColor256]}
    elif [[ $numColors -ge 16 ]]; then
        psColor=${config[psColor16]}
    elif [[ $numColors -ge 8 ]]; then
        psColor=${config[psColor8]}
    else
        psColor=-1
    fi

    PS_COLOR=$([[ $psColor -ge 0 ]] && tput setaf $psColor || echo '')
}

# Print a newline when the cursor is not at the top
#
# To be called from inside the definition of the PS1 variable
printNl () {
    local cRow cCol psRow

    # Row of the current cursor position; seen at:
    #     https://unix.stackexchange.com/questions/88296/get-vertical-cursor-position/183121#183121
    IFS=';' read -sdR -p $'\e[6n' cRow cCol
    psRow=${cRow#*[}

    # Newline (only when cursor not at top)
    # The \001 and \002 ANSI escape sequences are equivalent to the Bash escapes
    # \[ and \] respectively, and they're a "dirty" hack necessary for the
    # newline to work (\n by itself doesn't do anything here)
    [[ $psRow -eq 1 ]] && echo '' || echo -e "\n\001\002"
}

setPrompt ${config[psType]}


# --- Favorite text editor ---

temp[editor]=$(which ${config[editor]} 2>/dev/null)

if [[ -f "${temp[editor]}" ]]; then
    export EDITOR=${temp[editor]}
    export VISUAL=${temp[editor]}
fi


# --- Aliases ------------------------------------------------------------------

alias lsc='ls --color'
alias lsa='lsc -lAh'


# --- Cleanup ------------------------------------------------------------------

unset config temp
