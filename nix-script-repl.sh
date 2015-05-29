#!/usr/bin/env bash

Color_Off='\e[0m'
Red='\e[0;31m'
Green='\e[32m'

VERBOSE=0
EXPLAIN=0

for arg
do
    case $arg in
        "--verbose")
            VERBOSE=1
            ;;

        "--explain")
            EXPLAIN=1
            ;;

        "-e")
            EXPLAIN=1
            ;;

        *)
            ;;
    esac
done

stdout() {
    [ $VERBOSE -eq 1 ] && echo $*
}

stderr() {
    echo -e "${Red}$*${Color_Off}"
}

run() {
    [ $EXPLAIN -eq 1 ] && stderr $*; $*
}

__exists() {
    stdout "Exists '$1'? ..."
    which $1 >/dev/null 2>/dev/null
}

script_for() {
    echo "$(dirname ${BASH_SOURCE[0]})/nix-script-${1}.sh"
}

prompt() {
    echo -en "${Green}nix-script repl >${Color_Off} "
}

__run_if_exists() {
    [[ $(__exists $1) ]] && run $* || false
}

prompt
while read COMMAND ARGS
do
    if [[ $COMMAND =~ "quit" || $COMMAND =~ "q" ]]
    then
        exit 0
    fi

    stdout "Got '$COMMAND' with args '$ARGS'"

    NIX_COMMAND="nix-$COMMAND"
    NIXOS_COMMAND="nixos-$COMMAND"

    stdout "NIX_COMMAND     : '$NIX_COMMAND'"
    stdout "NIXOS_COMMAND   : '$NIXOS_COMMAND'"

    __run_if_exists $NIX_COMMAND $ARGS      && prompt && continue
    __run_if_exists sudo $NIX_COMMAND $ARGS && prompt && continue

    stdout "Searching for script for '$COMMAND'"
    SCRIPT=$(script_for $COMMAND)

    [ ! -f $SCRIPT ] && stderr "Not available: $COMMAND -> $SCRIPT" && prompt && continue
    [[ ! -x $SCRIPT ]] && stderr "Not executeable: $SCRIPT" && prompt && continue

    stdout "Calling: '$COMMAND $SCRIPT_ARGS'"
    $SCRIPT $SCRIPT_ARGS

    prompt
done

stdout "Ready. Bye-Bye!"

