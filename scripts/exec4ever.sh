#! /bin/bash

# todo : make sleep time configurable
# todo : redirect output to a file

source $HOME/.bash_logging

usage()
{
  echo "Usage : exec4ever cmd [{arguments}]"
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

while (true)
do
  $CMD "$@"
  sleep 3
done
