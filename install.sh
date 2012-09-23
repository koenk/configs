#!/bin/bash
#
# Installs all scripts in this repository using symlinks.
#
# Will put sudo in front of every command if needed. Set the do_root flag to
# false to disable any action that would need sudo. This will only install files
# into the user's home directory.
#

# Few basic options
do_root=true
make_backups=false
root_homedir="/root"

# Where are all destinations located
bashrc="$HOME/.bashrc"
bashrc_root="$root_homedir/.profile"

vimrc="$HOME/.vimrc"
vimrc_root="$root_homedir/.vimrc"
vimdir="$HOME/.vim"
vimdir_root="$root_homedir/.vim"

tmux="/etc/tmux.conf"

# How are the files called in the repository
local_dir="$( cd "$( dirname "$0" )" && pwd)"
local_bashrc="$local_dir/bashrc"
local_vimrc="$local_dir/vimrc"
local_vimdir="$local_dir/vim"
local_tmux="$local_dir/tmux.conf"

function do_install() {
    # Sudo stuff
    cmd_prefix=""
    if [ $# -eq 3 ]; then
        if ! $do_root; then
            echo " :: Ignoring root file $2"
            return
        else
            cmd_prefix="sudo "
        fi
    fi

    echo " :: Installing $1 as $2"

    # File already exists?
    if $cmd_prefix [ -e $2 ]; then
        if $make_backups; then
            cmd="mv "$2" "$2.bak""
        else
            cmd="rm "$2""
        fi
        echo "$cmd_prefix$cmd"
        $($cmd_prefix$cmd)
    fi

    cmd="ln -sT "$1" "$2""
    echo "$cmd_prefix$cmd"
    $($cmd_prefix$cmd)
}

do_install "$local_bashrc" "$bashrc"
do_install "$local_bashrc" "$bashrc_root" "root"
do_install "$local_vimrc" "$vimrc"
do_install "$local_vimrc" "$vimrc_root" "root"
do_install "$local_vimdir" "$vimdir"
do_install "$local_vimdir" "$vimdir_root" "root"
do_install "$local_tmux" "$tmux" "root"
