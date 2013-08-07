# Check for an interactive session
[ -z "$PS1" ] && return

shopt -s checkwinsize
case "$OSTYPE" in
    linux*)
        eval $(dircolors -b)
        shopt -s autocd
    ;;
esac

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
#  Use chromium for pdf, htm(l), images
_xspecs[chromium]='!*.@(pdf|htm?(l)|png|jpg|gif)'
complete -F _filedir_xspec chromium
#  Love opens .love files...
_xspecs[love]='!*.@(love)'
complete -F _filedir_xspec love

#
# Build a nice PS1 (prompt)
#
# Escape sequences for colors
RESET_COL="\[\e[0m\]"

# These are all bold/hi-intensity versions
BLACK="\[\e[1;90m\]"
RED="\[\e[1;91m\]"
GREEN="\[\e[1;92m\]"
YELLOW="\[\e[1;93m\]"
BLUE="\[\e[1;94m\]"
PURPLE="\[\e[1;95m\]"
CYAN="\[\e[1;96m\]"
WHITE="\[\e[1;97m\]"

# 'light' version of colors: no bold and/or darker
RED_S="\[\e[0;31m\]"
GREEN_D="\[\e[1;32m\]"
YELLOW_D="\[\e[1;33m\]"

# Determine color for user
user_col=${GREEN}
if [ ${EUID} -eq 0 ]; then
    # Root
    user_col=${RED}
elif [[ ${USER} != "$(logname 2>/dev/null)" ]]; then
    # Different user (e.g. after su)
    user_col=${PURPLE}
fi

# Determine what to display as hostname (and color)
hname=""
if [[ "${HOSTNAME}" == "koeserv" ]]; then
    hname="$CYAN@koeserv"
elif [[ "${HOSTNAME}" == "sremote" || "${HOSTNAME}" == "deze" ||
    "${USER}" == "koenk" ]]; then
    hname="$YELLOW@UvA"
elif [[ "${USER}" == "kkoning" ]]; then
    hname="$BLUE@DAS4,${HOSTNAME}"
elif [[ "$(who am i | awk '{print $5}')" != "" ]]; then
    # Hacky way of detecting ssh (env vars won't work when su'ing)
    hname="$WHITE@$HOSTNAME"
fi

# Git functions (mostly from https://github.com/nojhan/liquidprompt/)
# Determines the branch of the current directory, if this is a git repo
git_get_branch() {
    local gitdir="$(git rev-parse --git-dir 2>/dev/null)"
    [[ $? -ne 0 || ! $gitdir =~ (.*\/)?\.git.* ]] && return
    local branch="$(git symbolic-ref HEAD 2>/dev/null)"
    if [[ $? -ne 0 || -z "$branch" ]]; then
        # In detached head state, use commit instead
        branch="$(git rev-parse --short HEAD 2>/dev/null)"
    fi
    [[ $? -ne 0 || -z "$branch" ]] && return
    branch="${branch#refs/heads/}"
    echo "$branch"
}

# Determines whather there are uncommited changes in the current directory
git_has_changes() {
    local GD
    git diff --quiet >/dev/null 2>&1
    GD=$?

    local GDC
    git diff --cached --quiet >/dev/null 2>&1
    GDC=$?

    if [[ "$GD" -eq 1 || "$GDC" -eq 1 ]]; then
        echo -ne "1"
    fi
}

# Determines whether there are unpushed commits in the current directory
git_has_commits() {
    local branch
    branch=$(git_get_branch)
    if [[ -z "$branch" ]]; then
        return
    fi

    local remote
    remote="$(git config --get branch.${branch}.remote 2>/dev/null)"
    # If git has no upstream, use origin
    if [[ -z "$remote" ]]; then
        remote="origin"
    fi
    local remote_branch
    remote_branch="$(git config --get branch.${branch}.merge 2>/dev/null)"
    # Without any remote branch, use the same name
    if [[ -z "$remote_branch" ]]; then
        remote_branch="$branch"
    else
        remote_branch="$(basename "$remote_branch")"
    fi

    if [[ -n "$remote" && -n "$remote_branch" ]]; then
        local commits=$(git rev-list --no-merges --count $remote/${remote_branch}..${branch} 2>/dev/null)
        if [[ "$commits" -gt 0 ]]; then
            echo -ne "1"
        fi
    fi
}

# Function called every time prompt is shown, so current working dir can be
# taken into account
generate_prompt() {
    # Append red ! to path if no write perms in this dir
    local writeperms=""
    if [[ ! -w "$PWD" ]]; then
        writeperms="${RED_S}!"
    fi

    # Number of sleeping jobs (when Ctrl-Z was pressed)
    local stopped=$(jobs -s | wc -l | tr -d ' ')
    if [ $stopped -eq 0 ]; then
        stopped=""
    else
        stopped="$WHITE$stopped "
    fi

    # Git branch and status
    local git=""
    local git_branch=$(git_get_branch)
    if [[ ! -z "$git_branch" ]]; then
        local git_changes=$(git_has_changes)
        if [[ ! -z "$git_changes" ]]; then
            git=" $YELLOW_D"
        else
            git=" $GREEN_D"
        fi
        git="$git[$git_branch"

        local git_commits=$(git_has_commits)
        if [[ ! -z "$git_commits" ]]; then
            git="$git^"
        fi

        git="$git]"
    fi

    PS1="$user_col\u$hname $BLUE\w$writeperms$git $stopped$GREEN\$ $RESET_COL"
}
PROMPT_COMMAND=generate_prompt


# Set default options for some commands

case $OSTYPE in
    linux*)  alias ls='ls --color=auto' ;;
    darwin*) alias ls='ls -G' ;;
esac

alias grep='grep --color=auto'
alias grep='grep -i'
alias ack='ack -i'
alias df='df -h'
alias du='du -c -h'
alias locate='locate -i'
alias less='less -R' # Interpret ANSI color escape sequences
alias tmux='tmux -2' # Forces 256 color

# Shorthands, typo's and new commands
alias ll='ls -lhA'
alias l='ls'
alias sl='ls'
alias la='ls -a'
alias cd..='cd ..'
alias more='less'
alias v='vim -R -' # Piping into vim
alias hist='history|grep $1'
alias da='date "+%A, %B, %d, %Y [%T]"'
alias dul='du --max-depth=1'
alias cack='ack --color --group'
alias ackc='cack'
alias f='fg'
alias c='cd'
alias m='make'
alias g='grep'

# Git related shortcuts
alias gs='git status'
alias gc='git commit'
alias gco='git checkout'
alias gcl='git clone'
alias ga='git add'
alias gp='git pull'
alias gpr='git pull -r'
alias gd='git diff'
alias gb='git branch'
alias gbl='git blame'
alias gl="git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# If not root, prepend sudo when needed
if [ $UID -ne 0 ]; then
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
    if [ -f "$1" ] ; then
      case "$1" in
        *.tar.bz2)   tar xjf "$1"     ;;
        *.tar.gz)    tar xzf "$1"     ;;
        *.bz2)       bunzip2 "$1"     ;;
        *.rar)       unrar e "$1"     ;;
        *.gz)        gunzip "$1"      ;;
        *.tar)       tar xf "$1"      ;;
        *.tbz2)      tar xjf "$1"     ;;
        *.tgz)       tar xzf "$1"     ;;
        *.zip)       unzip "$1"       ;;
        *.Z)         uncompress "$1"  ;;
        *.7z)        7z x "$1"        ;;
        *)     echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}
alias e='extract'
alias x='extract'
