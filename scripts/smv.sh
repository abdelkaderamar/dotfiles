#!  /bin/bash -u
#
# Abdelkader Amar
#

### Logging ###############################################
source $HOME/.bash_logging

function usage()
{
    e_header Usage: $(basename "$0") '<HOST> [-l <limit in kilobits>|-h|-q] [files]'
    e_arrow    '-q        quiet mode (no log file)'
    e_arrow    '-h HOST   remote hostname'
    e_arrow    '-l LIMIT  set transfer limit in kilo bits (divide by 8 to equivalent in KB'
    e_arrow    '-d DIR    set remote dir (default is $HOME/smv_files)'
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
LIMIT=0

while [ $# -gt 0 ]
do
  case "$1" in
      -h) shift
	  HOST=$1
	  ;;
      -d) shift
	  REMOTE_DIR="$1"
	  ;;
      -q) 
	  ;;
      '-l') shift
	    LIMIT="$1"
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

append "$LOG_FILE" "###########################################################"
append "$LOG_FILE" "Starting at $(date)"
append "$LOG_FILE" "Moving to host $HOST the following files/directory:"
for file in "${FILES[@]}"
do
  append "$LOG_FILE" "  * $file"
done

ssh "$HOST" "mkdir -p $REMOTE_DIR"

for file in "${FILES[@]}"
do
    append "$LOG_FILE"  "Start copying [$file] ...."
    if [ "$LIMIT" -eq 0 ]
    then
	scp -r -p "$file" "$HOST":"$REMOTE_DIR" >> "$LOG_FILE" 2>&1
    else
	scp -r -p -l "$LIMIT" "$file" "$HOST":"$REMOTE_DIR" >> "$LOG_FILE" 2>&1
    fi
    res=$?
    if [ $res -eq 0 ]
    then
	append "$LOG_FILE" "... copying $file succeed => delete it"
	rm -fr "$file"  && append "$LOG_FILE"  "... $file deleted"
	res=$?
    else
	append "$LOG_FILE"  "failed to copy remotely $file (error code=[$res])" >> $LOG_FILE
    fi
done

append "$LOG_FILE" "Done at $(date)"
append "$LOG_FILE" "###########################################################"

exit $res

