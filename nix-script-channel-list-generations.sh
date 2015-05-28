#!/usr/bin/env bash

Color_Off='\e[0m'
Red='\e[0;31m'

sudo nix-env -p /nix/var/nix/profiles/per-user/root/channels --list-generations
