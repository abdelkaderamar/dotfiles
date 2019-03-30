#! /bin/bash

source $HOME/.bash_logging

usage()
{
  echo "Usage : cmd [{arguments}]"
}

add_log_separator() {
  LOG_FILE="$1"
  echo >> "$LOG_FILE"
  echo "##################################################" >> "$LOG_FILE"
  echo >> "$LOG_FILE"

}

if [ $# -eq 0 ]
then
  usage
  exit 1
fi

if [ $# -eq 1 -a "$1" == "-h" ]
then
  usage
  exit 0
fi

date +'%Y-%m-%d-%H:%M:%S'

CMD="$1"
shift

date=$(date +'%Y-%m-%d-%H:%M:%S')
LOG=`basename $0`-$CMD-$date.log
ERR=${LOG%.log}.err

echo Executing the following command at $(date) >> "$LOG"
echo "   $CMD $@" >> "$LOG"

add_log_separator "$LOG"

$CMD "$@" >> "$LOG" 2>> "$ERR"
res=$?

add_log_separator "$LOG"

echo "Finishing the execution at $(date) with result $res" >> $LOG

if [ $res -eq 0 ]
then
  STATUS="SUCCESS"
  verb="succeed"
else
  STATUS="ERROR"
  verb="failed"
fi
HOSTNAME=$(hostname)

MSG_TO_SEND="$STATUS. Command {$CMD} $verb at $(date) on host {$HOSTNAME}. Arguments=$@"

sms.sh "$MSG_TO_SEND"

if [ $? -eq 0 ]
then
  echo "SMS sent successfully" >> $LOG
else
  echo "Failed to send notification SMS [$res]" >> "$LOG"
fi

exit "$res"
