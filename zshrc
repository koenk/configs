setopt appendhistory autocd extendedglob nomatch notify
unsetopt beep

# More history
HISTFILE=~/.histfile
HISTSIZE=10000000
SAVEHIST=10000000

# Emacs mods
bindkey -e

for i in {0..9}; do
    bindkey -r "^[$i"
done

# Autocomplete
zstyle :compinstall filename '/home/koen/.zshrc'
autoload -Uz compinit
compinit

# Oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
COMPLETION_WAITING_DOTS="true" # Red dots whilst waiting for completion
plugins=(git)
ZSH_THEME="koenk"
zstyle ':omz:update' mode disabled
source $HOME/.oh-my-zsh/oh-my-zsh.sh

autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end
bindkey "^[Oc" forward-word
bindkey "^[Od" backward-word

fancy-ctrl-z () {
    if [[ $#BUFFER -eq 0 ]]; then
        BUFFER="fg"
        zle accept-line
    else
        zle push-input
        zle clear-screen
    fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# Powerline for PS1
#source /usr/share/zsh/site-contrib/powerline.zsh

# Load aliasses etc shared with bash
source $HOME/.shell_aliasses

# Load machine-local stuff (e.g. env vars)
source $HOME/.shell_local

