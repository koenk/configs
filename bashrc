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

# Search in history with up/down keys
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

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

# Load aliasses etc shared with bash
source $HOME/.shell_aliasses

# Load machine-local stuff (e.g. env vars)
source $HOME/.shell_local
