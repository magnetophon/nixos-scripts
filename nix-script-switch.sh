#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE[0]})/nix-utils.sh

CONFIG_DIR=

COMMAND="switch"

usage() {
    cat <<EOS

    $(help_synopsis "${BASH_SOURCE[0]}" "[-h] [-c <command>] [-g <git command>] -w <working directory> [-- args...]")

        -c <command>    Command for nixos-rebuild. See 'man nixos-rebuild'
        -g <git cmd>    Alternative git commit, defaults to 'tag -a'
        -w <path>       Path to your configuration git directory
        -h              Show this help and exit

        Everything after a double dash (--) will be passed to nixos-rebuild as
        additional parameters. For example:

            nix-script switch -c switch -- -I nixpkgs=/home/user/pkgs

$(help_end)
EOS
}

COMMAND=
ARGS=
WD=
TAG_NAME=
GIT_COMMAND=

while getopts "c:w:t:h" OPTION
do
    case $OPTION in
        c)
            COMMAND=$OPTARG
            stdout "COMMAND = $COMMAND"
            ;;
        w)
            WD=$OPTARG
            stdout "WD = $WD"
            ;;
        t)
            TAG_NAME=$OPTARG
            stdout "TAG_NAME = $TAG_NAME"
            ;;

        g)
            GIT_COMMAND=$OPTARG
            stdout "GIT_COMMAND = $GIT_COMMAND"
            ;;

        h)
            usage
            exit 1
            ;;
    esac
done

ARGS=$(echo $* | sed -r 's/(.*)\-\-(.*)/\2/')
stdout "ARGS = $ARGS"

if [[ -z "$WD" ]]
then
    stderr "No configuration git directory."
    stderr "Won't do anything"
    exit 1
fi

if [[ ! -d "$WD" ]]
then
    stderr "No directory: $WD"
    exit 1
fi

if [[ -z "$COMMAND" ]]
then
    COMMAND="switch"
fi

if [[ -z "$GIT_COMMAND" ]]
then
    GIT_COMMAND="tag -a"
fi

explain sudo nixos-rebuild $COMMAND $ARGS
REBUILD_EXIT=$?

if [[ $REBUILD_EXIT -eq 0 ]]
then
    LASTGEN=$(sudo nix-env -p /nix/var/nix/profiles/system --list-generations |\
        grep current | cut -d " " -f 2)
    sudo -k

    if [[ -z "$TAG_NAME" ]]
    then
        TAG_NAME="nixos-$LASTGEN-$COMMAND"
    fi

    explain git --git-dir="$WD/.git" --work-tree="$WD" $GIT_COMMAND "'$TAG_NAME'"

else
    stderr "Switching failed. Won't executing any further commands."
    exit $REBUILD_EXIT
fi

