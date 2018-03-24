#! /bin/bash -u

shopt -s nullglob

CMD="nice unrar x"
FAIL_DIR=failed
SLEEP_TIME=0
LOG=unrar_all.log

### Logging ###############################################
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
    e_success "unrar succeed"
    rm -v "$@"
  else
    e_error "unrar failed"
    mv -v "$@" "$FAIL_DIR"
  fi
  sleep $SLEEP_TIME
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
  esac
  shift
done


initialize

for f in *part001.rar
do
  e_header "Processing file $f"
  $CMD "$f" >> "$LOG"
  post_uncompress $? "${f%001.rar}"???.rar
done

for f in *part01.rar
do
  e_header "Processing file $f"
  $CMD "$f" >> "$LOG"
  post_uncompress $? "${f%01.rar}"??.rar
done

for f in *part1.rar
do
  e_header "Processing file $f"
  $CMD "$f" >> "$LOG"
  post_uncompress $? "${f%1.rar}"?.rar
done

for f in *.rar
do
  [[ "$f" =~ part([0-9]+).rar ]] && continue;
  e_header "Processing file $f"
  $CMD "$f" >> "$LOG"
  post_uncompress $? "$f"
done

if [ -d "$FAIL_DIR" -a -z "$(ls -A $FAIL_DIR)" ]
then
  rmdir "$FAIL_DIR"
else
  e_error "Directory [$FAIL_DIR] not empty"
fi
