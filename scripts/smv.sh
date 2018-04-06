#!  /bin/bash -u
#
# Abdelkader Amar
#

### Logging ###############################################
source $HOME/.bash_logging

function usage()
{
  e_header Usage: $(basename "$0") '<HOST> [files]'
  echo
}

function append()
{
  log_file=$1
  shift
  for line in "$@"
  do
    echo "$line" >> "$log_file"
  done
}

HOST=''
REMOTE_DIR=smv_files
FILES=()

while [ $# -gt 0 ]
do
  case "$1" in
    -h) shift
    HOST=$1
    ;;
    -d) shift
    REMOTE_DIR=$1
    ;;
    *) FILES+=("$1")
    ;;
  esac
  shift
done

if [ x$HOST == x ]
then
  usage
  exit 1
fi

LOG_FILE=smv-${HOST}.log

if [ ${#FILES[@]} -eq 0 ]
then
  append "$LOG_FILE" "No file to transfer"
  exit 0
fi

append "$LOG_FILE" "Moving to host $HOST the following files/directory:"
for file in "${FILES[@]}"
do
  append "$LOG_FILE" "  * $file"
done

ssh "$HOST" "mkdir -p $REMOTE_DIR"

for file in "${FILES[@]}"
do
  append "$LOG_FILE"  "Start copying [$file] ...."
  scp -r "$file" "$HOST":"$REMOTE_DIR" >> "$LOG_FILE" 2>&1
  res=$?
  if [ $res -eq 0 ]
  then
    append "$LOG_FILE" "... copying $file succeed => delete it"
    rm -fr "$file"  && append "$LOG_FILE"  "... $file deleted"
  else
    append "$LOG_FILE"  "failed to copy remotely $file (error code=[$res])" >> $LOG_FILE
  fi
done
