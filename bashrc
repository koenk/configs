# Check for an interactive session
[ -z "$PS1" ] && return

shopt -s checkwinsize
shopt -s autocd

shopt -s histappend
export HISTSIZE=100000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth

export EDITOR=vim
export BROWSER=chromium

# Search in history with up/down keys
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

# Fix some autocomplete stuff
#  Use chromium for pdf, htm(l)
_xspecs[chromium]='!*.@(pdf|htm?(l))'
complete -F _filedir_xspec chromium
#  Love opens .love files...
_xspecs[love]='!*.@(love)'
complete -F _filedir_xspec love

# Build a nice PS1
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
alias ack='ack -i'
alias cd..='cd ..'
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
alias gpr='git pull -r'
alias gd='git diff'
alias gb='git blame'
alias gl="git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# If not root, prepend sudo when needed
if [ $UID -ne 0 ]; then
	#alias reboot='sudo reboot'
	#alias poweroff='sudo poweroff'
	alias pacman='sudo pacman'
    alias netcfg='sudo netcfg'
    alias wifi-menu='sudo wifi-menu'
    alias vpnc='sudo vpnc'
    alias updatedb='sudo updatedb'
fi

# Very specific stuff
alias mountuva='sshfs koenk@sremote.science.uva.nl: /media/uva/'
alias mountkoeserv='sshfs -o allow_other,default_permissions koen@koeserv:/ /media/koeserv'

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
        echo "cd `dirname "$@"`"
        builtin cd "`dirname "$@"`"
    else
        builtin cd "$@" 2> /dev/null

        # I have a bad habit of typing 'l' (alias of ls) before pressing the
        # enter key for the cd line. Fix that here too while we're at it...
        if [ ! $? = 0 ] && [[ $@ =~ /l$ ]]; then
            builtin cd "`dirname "$@"`"
            l
        fi
    fi
}

# Extracts any archive format you throw at it (kinda)
extract () {
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   tar xjf $1     ;;
        *.tar.gz)    tar xzf $1     ;;
        *.bz2)       bunzip2 $1     ;;
        *.rar)       unrar e $1     ;;
        *.gz)        gunzip $1      ;;
        *.tar)       tar xf $1      ;;
        *.tbz2)      tar xjf $1     ;;
        *.tgz)       tar xzf $1     ;;
        *.zip)       unzip $1       ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1        ;;
        *)     echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}
