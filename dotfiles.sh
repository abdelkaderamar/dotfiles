#!/usr/bin/env bash

[[ "$1" == "source" ]] || \

    echo 'Dotfiles - Abdelkader Amar - https://github.com/abdelkaderamar'

if [[ "$1" == "-h" || "$1" == "--help" ]]; then cat <<HELP
Usage: $(basename "$0")
See the README for documentation.
https://github.com/abdelkaderamar/dotfiles
Licensed under the MIT license.
HELP
exit; fi

DO=""
while [ $# -gt 0 ]
do
    case "$1" in
        '-dry') DO="echo";;
    esac
    shift
done

### Logging ################################################
function e_header()  { echo -e "\n\033[1m$@\033[0m"; }
function e_success() { echo -e " \033[1;32m✔\033[0m  $@"; }
function e_error()   { echo -e " \033[1;31m✖\033[0m  $@"; }
function e_arrow()   { echo -e " \033[1;34m➜\033[0m  $@"; }
############################################################

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo $DOTFILES_DIR

e_header "Starting dotfile installation ..."

source "$DOTFILES_DIR/init/create_dirs.sh"

source "$DOTFILES_DIR/init/apt.sh"

source "$DOTFILES_DIR/bash/bash_setup.sh"

e_header "dotfiles installation done"
