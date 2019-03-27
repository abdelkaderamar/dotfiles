#! /bin/bash

source $HOME/.bash_logging

usage()
{
  echo "Usage : cmd [{arguments}]"
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

CMD="$1"

shift

$CMD "$@"

res=$?

if [ $res -eq 0 ]
then
  STATUS="SUCCESS"
  verb="succeed"
else
  STATUS="ERROR"
  verb="failed"
fi
HOSTNAME=$(hostname)

MSG_TO_SEND="$STATUS. Command {$CMD} $verb at $(date) on host {$HOSTNAME}"

sms.sh "$MSG_TO_SEND"
