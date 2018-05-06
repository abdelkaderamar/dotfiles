#! /bin/bash -u

function usage()
{
  echo "Usage regex_mv.sh <regexp1> <regexp2> [-r]"
  echo
  echo "Where "
  echo "  regexp1 is the regular expression to replace"
  echo "  regexp2 is the replace regular expression"
  echo "  -r is used to rename file. Otherwise only a preview if displayed"
}

if [ $# -ne 2 -a $# -ne 3 ]
then
  usage
  exit 1
fi

source $HOME/.bash_logging

regexp1="$1"
regexp2="$2"

RENAME=false

if [ $# -eq 3 ]
then
  if [ $3 = '-r' ]
  then
    RENAME=true
  fi
fi

for f in *
do
  name=`echo "$f" | sed "s|$regexp1|$regexp2|g"`

  [[ "$name" == "$f" ]] && continue

  if ( $RENAME )
  then
    mv -iv "$f" "$name"
  else
    e_arrow "$f" ' -> ' "$name"
  fi
done
