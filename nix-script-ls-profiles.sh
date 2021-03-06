#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE[0]})/nix-utils.sh

profiledir=/nix/var/nix/profiles

usage() {
    cat <<EOS >&2
    $(help_synopsis "${BASH_SOURCE[0]}" "[--system | -s] [--user | -u] [-n] [-h]")

    --system | -s           | Show system profiles
    --user | -u             | Show user profiles
    --system-profiles | -p  | Show other system profiles
    -n                      | Show only profile numbers
    -h                      | Show this help and exit

$(help_end)
EOS
}

SYSTEM=0
USER=0
SYSPROF=0
NUMBERS=0

for arg
do

    case $arg in
        "--system" )
            SYSTEM=1
            ;;

        "-s" )
            SYSTEM=1
            ;;

        "-u" )
            USER=1
            ;;

        "--user" )
            USER=1
            USER_NAMES=$USER
            ;;

        "--system-profiles" )
            SYSPROF=1
            ;;

        "-p" )
            SYSPROF=1
            ;;

        "-n" )
            NUMBERS=1
            ;;

        "-h" )
            usage
            exit 0
            ;;

        "*")
            ;;
    esac
done

if (( $SYSTEM == 0 && $USER == 0 && $SYSPROF == 0 ))
then
    usage
    exit 1
fi

numberfilter() {
    pref="$1"
    if (( $NUMBERS == 0 ))
    then
        cat
    else
        if (( ($SYSTEM != 0 && $USER != 0) ||
              ($SYSTEM != 0 && $SYSPROF != 0) ||
              ($USER != 0 && $SYSPROF != 0) ))
        then
            cut -d - -f 2 | sort -n | sed -r "s:^(.*):$pref\1:"
        else
            cut -d - -f 2 | sort -n
        fi
    fi
}

list() {
    ls "$profiledir/$1" | grep -E "$2" | numberfilter "$3"
}

if (( $SYSTEM == 1 ))
then
    list "" "^system-.*-link" "system/"
fi

if (( $USER == 1 ))
then
    for username in $USER_NAMES
    do
        list "per-user/$username" "^profile-.*-link" "user/$username/"
    done
fi

if (( $SYSPROF == 1 ))
then
    for entry in $(ls "$profiledir/system-profiles" | grep -v ".*-.*-link")
    do
        list "system-profiles/" "^$entry-.*-link" "system/$entry/"
    done
fi
