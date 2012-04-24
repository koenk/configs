
# Check for an interactive session
[ -z "$PS1" ] && return

shopt -s histappend
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTCONTORL=ignoreboth

export EDITOR=nano
#export PACMAN=pacman-color

#PS1='\[\033[01;32m\][\u@\h \W]\[\033[00m\]\$ '
PS1='\[\e[01;32m\]\u\[\e[m\]\[\e[01;36m\]@koeserv\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[1;32m\]\$\[\e[m\] \[\e[00m\]'

eval $(dircolors -b)

alias ls='ls --color=auto'
alias grep='grep --color=auto'

alias ll='ls -lhA'
alias l='ls'
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

if [ $UID -ne 0 ]; then
	alias reboot='sudo reboot'
	alias poweroff='sudo poweroff'
	alias update='sudo pacman -Su'
	alias pacman='sudo pacman'
fi

# Very specific stuff
alias mountuva='sshfs koenk@sremote.science.uva.nl: /media/uva/'
alias mountkoeserv='sshfs koeserv: /media/koeserv'
alias sshvp='ssh vp@home.bluewolf.nl -p 5108'

# Find a specific string IN a file (in all subdirs)
function findif() {
  find . -exec grep -n "$@" "{}" \; -print
}

# mkdir & cd into it
function mc() {
  mkdir -p "$*" && cd "$*" && pwd
}

# cd & ll
#alias lc="cl"
function cl () {
   if [ $# = 0 ]; then
      cd && ll
   else
      cd "$*" && ll
   fi
}
