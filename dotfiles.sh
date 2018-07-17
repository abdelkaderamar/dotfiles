#!/bin/bash

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
OPT_APT_INSTALL=false
OPT_SOFT_INSTALL=false
OPT_DEV_SETUP=false
OPT_BASH_SETUP=true

while [ $# -gt 0 ]
do
  case "$1" in
    '-dry')  DO="echo" ;;
    '-dir')  OPT_CREATE_DIR=true ;;
    '-apt')  OPT_APT_INSTALL=true ;;
    '-soft') OPT_SOFT_INSTALL=true ;;
    '-dev')  OPT_DEV_SETUP=true;;
    '-all')  OPT_CREATE_DIR=true
      OPT_APT_INSTALL=true
      OPT_SOFT_INSTALL=true
      OPT_DEV_SETUP=true
      ;;

  esac
  shift
done

### Logging ################################################
function e_header()  { echo -e "\n\033[1m$@\033[0m"; }
function e_success() { echo -e " \033[1;32m✔\033[0m  $@"; }
function e_error()   { echo -e " \033[1;31m✖\033[0m  $@"; }
function e_arrow()   { echo -e " \033[1;34m➜\033[0m  $@"; }
function e_warn()    { echo -e " \033[1;31m➜\033[0m  $@"; }
############################################################

apt_keys=()
declare -A apt_sources
apt_packages=()

export apt_keys
export apt_sources
export apt_packages

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo $DOTFILES_DIR

e_header "Starting dotfile installation ..."

source "$DOTFILES_DIR/init/create_dirs.sh"

if ( $OPT_APT_INSTALL )
then
  if ( $OPT_DEV_SETUP )
  then
    apt_packages+=(gcc clang)
    # To compile gcc from sources
    apt_packages+=(libgmp-dev libmpc-dev libmpfr-dev gcc-multilib g++-multilib libc6-dev-i386)
    apt_packages+=(git)
    apt_packages+=(lcov)
    apt_packages+=(gcovr)
    apt_packages+=(libboost-all-dev)
    apt_packages+=(libtool autoconf)
    apt_packages+=(libncurses5-dev cmake cmake-curses-gui)
    apt_packages+=(ruby-dev ruby-bundler)
    apt_packages+=(clang-format)
    apt_packages+=(libxerces-c-dev)
    apt_packages+=(qtcreator kdevelop  qtbase5-dev qtdeclarative5-dev libqt5webkit5-dev)
    apt_packages+=(libcpprest-dev)
    apt_packages+=(dh-make bzr-builddeb texinfo)
    apt_packages+=(libspdlog-dev)
    apt_packages+=(python-pip)

  fi
  source "$DOTFILES_DIR/init/apt.sh"
fi

if ( $OPT_SOFT_INSTALL )
then
  source "$DOTFILES_DIR"/init/soft.sh
fi

if ( $OPT_DEV_SETUP )
then
  source "$DOTFILES_DIR"/init/dev.sh
fi

if ( $OPT_BASH_SETUP )
then
  source "$DOTFILES_DIR/bash/bash_setup.sh"
fi

e_header "dotfiles installation done"
echo
