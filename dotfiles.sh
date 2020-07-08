#!/bin/bash 

function e_header()  { echo -e "\n\033[1m$@\033[0m"; }
function e_success() { echo -e " \033[1;32m✔\033[0m  $@"; }
function e_error()   { echo -e " \033[1;31m✖\033[0m  $@"; }
function e_arrow()   { echo -e " \033[1;34m➜\033[0m  $@"; }
function e_warn()    { echo -e " \033[1;31m➜\033[0m  $@"; }
function echo_and_exit()
{
  exit_code=$1
  shift
  e_error "$@"
  exit $exit_code
}

function print_usage()
{
  echo "Available options :"
  echo "  -dry  do not execute actions"
  echo "  -dir  create directories structure"
  echo "  -apt  install apt software"
  echo "  -snap     install snap software"
  echo "  -soft     install software from sources"
  echo "  -dev      install development tools (to combine with -apt)"
  echo "  -profile  the profile of the host. Available profiles are"
  echo "             - pi3 (raspberry 3 used as a server)"  
  echo "             - pi4 (raspberry 4 used as a media center and a server)"  
  echo "             - server32"  
  echo "             - server64"  
  echo "             - dev"  
  echo "             - netbook32"
  echo "             - oneprovider"
}

function read_profile()
{
    PROFILE=$1
    case "$PROFILE" in
	'pi3')
	    pi3_profile=true
	    ;;
	'pi4')
	    pi4_profile=true
	    ;;
	'server32')
	    server32_profile=true
	    ;;
	'server64')
	    server64_profile=true
	    ;;
	'dev')
	    dev_profile=true
	    ;;
	'netbook32')
	    netbook32_profile=true
	    ;;
	'oneprovider')
	    oneprovider_profile=true
	    ;;
	*)
	    e_error "Unknown profile $PROFILE"
	    exit 3
	    ;;
    esac
}

echo 'Dotfiles - Abdelkader Amar - https://github.com/abdelkaderamar'

for arg in "$@"
do
    if [[ "$arg" == "-h" || "$arg" == "--help" ]];
    then
	cat <<HELP
Usage: $(basename "$0")
See the README for documentation.
https://github.com/abdelkaderamar/dotfiles
Licensed under the MIT license.
HELP

	print_usage
	
	exit
    fi
done

### Logging ################################################
function e_header()  { echo -e "\n\033[1m$@\033[0m"; }
function e_success() { echo -e " \033[1;32m✔\033[0m  $@"; }
function e_error()   { echo -e " \033[1;31m✖\033[0m  $@"; }
function e_arrow()   { echo -e " \033[1;34m➜\033[0m  $@"; }
function e_warn()    { echo -e " \033[1;31m➜\033[0m  $@"; }
############################################################


DO=""
OPT_APT_INSTALL=false
OPT_SNAP_INSTALL=false
OPT_SOFT_INSTALL=false
OPT_DEV_SETUP=false
OPT_BASH_SETUP=true
OPT_APT_MULTIMEDIA=false
PROFILE=''

# Profiles #################################################
pi3_profile=false
pi4_profile=false
server32_profile=false
server64_profile=false
dev_profile=false
netbook32_profile=false
oneprovider_profile=false
############################################################

while [ $# -gt 0 ]
do
  case "$1" in
    '-dry')  DO="echo" ;;
    '-dir')  OPT_CREATE_DIR=true ;;
    '-apt')  OPT_APT_INSTALL=true ;;
    '-snap') OPT_SNAP_INSTALL=true ;;
    '-soft') OPT_SOFT_INSTALL=true ;;
    '-dev')  OPT_DEV_SETUP=true;;
    '-media') OPT_APT_MULTIMEDIA=true;;
    '-all')  OPT_CREATE_DIR=true
      OPT_APT_INSTALL=true
      OPT_SOFT_INSTALL=true
      OPT_DEV_SETUP=true
      ;;
    '-profile')
	shift
        read_profile $1
	;;
  esac
  shift
done


if ( $OPT_APT_INSTALL )
then
    if [ -z "$PROFILE" ]
    then
        e_error "Set a profile for -apt option (-profile <profile>)"
	exit 2
    fi
    echo $PROFILE
fi

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
    apt_packages+=(rustc)
fi


if ( $OPT_APT_MULTIMEDIA )
then
  source "$DOTFILES_DIR/init/multimedia.sh"
fi


if ( $OPT_APT_INSTALL )
then
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

if ( $OPT_SNAP_INSTALL )
then
  source "$DOTFILES_DIR/init/snap.sh"
fi


e_header "dotfiles installation done"
echo
