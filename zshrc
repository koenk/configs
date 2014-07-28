setopt appendhistory autocd extendedglob nomatch notify
unsetopt beep

# More history
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=1000000

# Emacs mods
bindkey -e

# Autocomplete
zstyle :compinstall filename '/home/koen/.zshrc'
autoload -Uz compinit
compinit

# Oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
COMPLETION_WAITING_DOTS="true" # Red dots whilst waiting for completion
plugins=(git ssh mosh zsh-syntax-highlighting)
source $HOME/.oh-my-zsh/oh-my-zsh.sh

# Powerline for PS1
source /usr/share/zsh/site-contrib/powerline.zsh

# Load aliasses etc shared with bash
source $HOME/.shell_aliasses

# Load machine-local stuff (e.g. env vars)
source $HOME/.shell_local

