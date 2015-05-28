#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE[0]})/nix-utils.sh

usage() {
    cat <<EOS
    $(help_synopsis "${BASH_SOURCE[0]}" "[-h] [-g <n>]")

        -g <n>  Generation to checkout
        -h      Show this help and exit

$(help_end)
EOS
}

# no generation by now
GEN=

while getopts "hg:" OPTION
do
    case $OPTION in
        g)
            stdout "Option GEN = $OPTARG"
            GEN=$OPTARG
            ;;
        h)
            usage
            exit 0
            ;;

        *)
            ;;
    esac
done

if [[ -z "$GEN" ]];
then
    stderr "No generation number passed"
    exit 1
fi

CHANNELS=/nix/var/nix/profiles/per-user/root/channels

stdout "Executing checkout. Password cache will be reset afterwards"
sudo nix-env -p $CHANNELS -G $N

stdout "Resetting sudo password"
sudo -k

