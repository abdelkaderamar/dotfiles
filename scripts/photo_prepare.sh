#! /bin/bash -u

source $HOME/.bash_logging

# To customize
PROCESSING_DIR="To Process2"

usage()
{
    echo "Usage"
    echo "    $(basename $0) <dir>"
}

if [ $# -lt 1 ]
then
    usage
    exit 1
fi

dir="$1"

use_millisecond=false

if [ $# -ge 2 ]
then
  if [ "$2" == "-ms" ]
  then
    use_millisecond=true
  fi
fi

current_dir=$(basename "$(pwd)")

echo "Current dir = $current_dir"
if [ "$current_dir" != "$PROCESSING_DIR" ]
then
    echo_and_exit 1 "Current dir is not processing dir [$PROCESSING_DIR]"
fi

e_header "Do you confirm the following ? "
e_arrow  "The directory to process [$dir]"

echo -n "yes/no ? "

read l

if [ "$l" != "yes" ]
then
    exit 2
fi

if ( $use_millisecond )
then
  exiftool  '-FileName<./${DateTimeOriginal}${subsectimeoriginal;$_.=0 x(3-length)}.%e' -d '%Y-%m-%d_%H%M%S%%-C'  -P -r -progress "$dir"
else
  exiftool  '-FileName<./${DateTimeOriginal}' -d '%Y-%m-%d_%H%M%S%%-c.%%e'  -P -r -progress "$dir"
  exiftool  '-FileName<./${CreateDate}' -d '%Y-%m-%d_%H%M%S%%-c.%%e'  -P -r -progress "$dir"
fi
