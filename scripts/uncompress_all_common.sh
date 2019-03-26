#! /bin/bash -u

shopt -s nullglob

FAIL_DIR=failed
SLEEP_TIME=0
FILES_TO_DEL=()
SUFFIX=''

### Logging ###############################################
source $HOME/.bash_logging

### Initialize the environment ############################
function initialize()
{
  mkdir -p $FAIL_DIR
}

### if the previous operation (must be uncompression) #####
### succeed the files are removed, othewise move to #######
### $FAIL_DIR #############################################
function post_uncompress()
{
  local result=$1
  shift
  [[ $# -gt 0 ]] || return
  if [ $result -eq 0 ]
  then
    e_success "uncompress succeed"
    rm -v "$@"
  else
    e_error "uncompress failed"
    mv -v "$@" "$FAIL_DIR"
  fi
  if [ ${#FILES_TO_DEL[@]} -gt 0 ]
  then
    for extension in ${FILES_TO_DEL[@]}
    do
      rm -f *.${extension}
    done
  fi
  sleep $SLEEP_TIME
}

### Delete FAIL_DIR if empty, otherwise print an error messge
function terminate_uncompress()
{
  if [ -d "$FAIL_DIR" -a -z "$(ls -A $FAIL_DIR)" ]
  then
    rmdir "$FAIL_DIR"
  else
    e_error "Directory [$FAIL_DIR] not empty"
  fi
}

### Add a suffix to all extracted files
function add_suffix()
{
  local suffix="$1"
  local extract_dir="$2"
  for filename in ${extract_dir}/*
  do
    extension="${filename##*.}"
    n="${filename%.*}"
    mv "$filename" "${n}.${suffix}.${extension}"
  done
}
### Options ###############################################
while [ $# -gt 0 ]
do
  case "$1" in
    '-f') shift
    FAIL_DIR=$1
    ;;
    '-s') shift
    SLEEP_TIME=$1
    ;;
    '-del')  shift
    FILES_TO_DEL+=($1)
    ;;
    '-add') shift
    SUFFIX="$1"
    ;;
    '-nolog')
    LOG=/dev/null
    ;;
    '-q')
    LOG=/dev/null
    ;;
  esac
  shift
done


initialize
