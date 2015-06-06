#!/usr/bin/env bash

Color_Off='\e[0m'
Red='\e[0;31m'
Green='\e[0;32m'

stderr() {
    echo -e "${Red}[$(basename $0)]: ${*}${Color_Off}" >&2
}

stdout() {
    [[ $VERBOSE -eq 1 ]] && echo -e "${Green}[$(basename $0)]:${Color_Off} $*"
}

scriptname_to_command() {
    if [[ -z "$2" ]]
    then
        echo "$1" | sed 's,^\.\/nix-script-,,' | sed 's,\.sh$,,'
    else
        echo "$1" | sed "s,^\.\/${2}-,," | sed 's,\.sh$,,'
    fi
}

help_synopsis() {
    SCRIPT=$(scriptname_to_command $1); shift
    echo "usage: nix-script $SCRIPT $*"
}

help_end() {
    echo -e "\tAdding '-v' before the '$1' command turns on verbosity"
    echo -e ""
    echo -e "\tReleased under terms of GPLv2"
    echo -e "\t(c) 2015 Matthias Beyer"
    echo ""
}

explain() {
    stdout "$*"
    $*
}

grep_generation() {
    $* | grep current | cut -d " " -f 2
}

current_system_generation() {
    grep_generation "sudo nix-env -p /nix/var/nix/profiles/system --list-generations"
}

current_user_generation() {
    grep_generation "nix-env --list-generations"
}

# Argument 1: Caller script name, format: "nix-script"
caller_util_all_commands() {
    find $(dirname ${BASH_SOURCE[0]}) -type f -name "${1}-*.sh"
}

# Argument 1: Caller script name, format: "nix-script"
caller_util_list_subcommands_for() {
    for cmd in $(caller_util_all_commands $1)
    do
        scriptname_to_command "$cmd" "$1"
    done
}

# Argument 1: Caller script name
# Argzment 2: Command name
caller_util_script_for() {
    echo "$(dirname ${BASH_SOURCE[0]})/${1}-${2}.sh"
}

# Argument 1: Caller script name
# Argzment 2: Command name
caller_util_get_script() {
    SCRIPT=$(caller_util_script_for $1 $2)

    if [ ! -f $SCRIPT ]
    then
        stderr "Not available: $COMMAND -> $SCRIPT"
        exit 1
    fi

    if [[ ! -x $SCRIPT ]]
    then
        stderr "Not executeable: $SCRIPT"
        exit 1
    fi

    echo "$SCRIPT"
}
