#! /bin/bash -u

source $HOME/.bash_logging

# To customize
PROCESSING_DIR="To Process2"

usage()
{
    echo "Usage"
    echo "    $(basename $0) <dir>"
}

if [ $# -ne 1 ]
then
    usage
    exit 1
fi

dir="$1"

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

exiftool  '-FileName<./${DateTimeOriginal}' -d '%Y-%m-%d_%H%M%S.%%e'  -P -r -progress "$dir"
