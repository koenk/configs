
# Check for an interactive session
[ -z "$PS1" ] && return

shopt -s checkwinsize
shopt -s autocd

shopt -s histappend
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTCONTORL=ignoreboth

#export EDITOR=nano
export EDITOR=vim
export BROWSER=chromium


RED="\[\e[1;31m\]"
GREEN="\[\e[1;32m\]"
BLUE="\[\e[1;34m\]"
CYAN="\[\e[1;36m\]"
YELLOW="\[\e[1;93m\]"
RESET_COL="\[\e[0m\]"


user_col=${GREEN}
if [ $UID -eq 0 ]; then
    user_col=${RED}
fi

hname=""
if [[ "${HOSTNAME}" == "koeserv" ]]; then
    hname="$CYAN@koeserv"
elif [[ "${HOSTNAME}" == "sremote" || "${HOSTNAME}" == "deze" ||
    "${USER}" == "koenk" ]]; then
    hname="$YELLOW@UvA"
elif [[ "${USER}" == "kkoning" ]]; then
    hname="$BLUE@DAS4,${HOSTNAME}"
fi


PS1="$user_col\u$hname $BLUE\w $GREEN\$ $RESET_COL"

eval $(dircolors -b)

alias ls='ls --color=auto'
alias grep='grep --color=auto'

alias ll='ls -lhA'
alias l='ls'
alias sl='ls'
alias la='ls -a'
alias grep='grep -i'
alias cd..='cd ..'
alias ..='cd ..'
alias df='df -h'
alias du='du -c -h'
alias locate='locate -i'

alias more='less'
alias hist='history|grep $1'
alias da='date "+%A, %B, %d, %Y [%T]"'
alias dul='du --max-depth=1'
alias tmux='tmux -2' # Forces 256 color

alias gs='git status'
alias gc='git commit'
alias ga='git add'
alias gp='git pull'
alias gd='git diff'

if [ $UID -ne 0 ]; then
	alias reboot='sudo reboot'
	alias poweroff='sudo poweroff'
	alias update='sudo pacman -Su'
	alias pacman='sudo pacman'
fi

# Very specific stuff
alias mountuva='sshfs koenk@sremote.science.uva.nl: /media/uva/'
alias mountkoeserv='sshfs koeserv:/ /media/koeserv'

# Find a specific string IN a file (in all subdirs)
function findif() {
  find . -exec grep -n "$@" "{}" \; -print
}

# mkdir & cd into it
function mkc() {
  mkdir -p "$*" && cd "$*" && pwd
}

# cd & ll
function cl () {
   if [ $# = 0 ]; then
      cd && ll
   else
      cd "$*" && ll
   fi
}

# Rewrite cd to accept files as path (cd into path containing file)
function cd() {
    if [ ! $# = 0 ] && [[ -f $@ ]]; then
        echo "cd `dirname $@`"
        builtin cd `dirname $@`
    else
        builtin cd $@
    fi
}
