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
  MSG_TO_SEND="SUCCESS. Command [$CMD] succeed at $(date)"
else
  MSG_TO_SEND="ERROR. Command [$CMD] failed at $(date)"
fi

sms.sh "$MSG_TO_SEND"
