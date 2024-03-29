#!/bin/bash
#
# Installs all scripts in this repository using symlinks.
#

# Simply remove files if they already exist or make backups?
make_backups=false

function do_install() {
    local_dir="$( cd "$( dirname "$0" )" && pwd)"
    local_file="$local_dir/$1"
    target_file="$HOME/$2"
    target_dir="$(dirname "$target_file")"

    if [ ! -d "$target_dir" ]; then
        echo " :: Creating $target_dir"
        mkdir -p "$target_dir"
    fi

    echo " :: Installing $local_file as $target_file"

    # File already exists?
    if [ -e $target_file ]; then
        if $make_backups; then
            cmd="mv "$target_file" "$target_file.bak""
        else
            cmd="rm "$target_file""
        fi
        #echo "$cmd"
        $($cmd)
    fi
    if [ $# -eq 3 ]; then
        cmd="cp "$local_file" "$target_file""
    else
        cmd="ln -sT "$local_file" "$target_file""
    fi
    #echo "$cmd"
    $($cmd)
}

# Install oh-my-zsh (to ~/.oh-my-zsh)
curl -L http://install.ohmyz.sh | sh

# Symlink(/copy) files
do_install "bashrc" ".bashrc"
do_install "zshrc" ".zshrc"
do_install "shell_aliasses" ".shell_aliasses"
do_install "shell_local" ".shell_local" "copy instead of symlink"
do_install "vimrc" ".vimrc"
do_install "vim" ".vim"
do_install "Xresources" ".Xresources"
do_install "gitconfig" ".gitconfig"
do_install "global_gitignore" ".global_gitignore"
do_install "koenk.zsh-theme" ".oh-my-zsh/themes/koenk.zsh-theme"

# Let Vundle install all git plugins
mkdir -p vim/bundle
cd vim/bundle
git clone https://github.com/gmarik/Vundle.vim.git
vim +PluginInstall +qall
