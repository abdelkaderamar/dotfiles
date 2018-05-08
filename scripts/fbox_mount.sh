#! /bin/bash

source $HOME/.bash_logging

FREEBOX_MOUNT_DIR=/mnt/freebox
if [ ! -d "$FREEBOX_MOUNT_DIR" ]
then
  sudo mkdir -p "$FREEBOX_MOUNT_DIR"
fi

function usage()
{
  echo "Usage:  $(basename $0) [-h|-u]"
  echo
  echo "  -h : print help message"
  echo "  -u : umount Freebox drive (if mounted)"
}

function umount_fb_drive()
{
  if  grep -qs "$FREEBOX_MOUNT_DIR" /proc/mounts
  then
    e_arrow "Start umounting Freebox drive ..."
    sudo umount "$FREEBOX_MOUNT_DIR"
    res=$?
    if [ $res -eq 0 ]
    then
      e_success "Freebox drive umounted successfuly"
    else
      e_error "Failed to umount Freebox drive"
    fi
    exit $res
  else
    e_arrow "Freebox drive not mounted"
    exit 0
  fi

}

if [ $# -gt 1 ]
then
  e_error "Syntax error"
  usage
  exit 1
fi

if [ $# -eq 1 ]
then
  case $1 in
    -h) usage
    exit 0
    ;;
    -u) umount_fb_drive
    ;;
    *) e_error "Unknow option $1"
    exit 1
    ;;
  esac
fi

# Here, we cant to mount the drive (not -h neither -u)

if  grep -qs "$FREEBOX_MOUNT_DIR" /proc/mounts
then
  e_arrow "Freebox drive already mounted"
  exit 0
fi

e_arrow "Start mounting Freebox drive ..."

sudo mount -t cifs //mafreebox.freebox.fr/Disque\ dur  "$FREEBOX_MOUNT_DIR" \
  -o user=freebox,password=password,uid=1000,gid=1000,rw,vers=1.0

res=$?
if [ $res -eq 0 ]
then
  e_success "Freebox drive mounted successfuly"
else
  e_error "Failed to mount Freebox drive"
fi

exit $res
