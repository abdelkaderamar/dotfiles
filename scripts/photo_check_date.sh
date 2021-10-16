#! /bin/bash -u

source $HOME/.bash_logging

usage()
{
    echo "Usage"
    echo "    $(basename $0) <dir> [year]"
    echo ""
    echo " - year is the lowest accepted date"
}

if [ $# -lt 1 ]
then
    usage
    exit 1
fi

dir="$1"

if [ $# -ge 2 ]
then
    year=$2
else
    year=2004
fi

e_header "Looking for file without creation date"

exiftool -filename -filemodifydate -createdate -r -if '(not $datetimeoriginal) and $filetype eq "JPEG"' "$dir"

e_header "Looking for file with creation date before $year"

exiftool -s -filename -createdate -r "$dir" | grep -B 2 "^CreateDate[ ]\+ : ${year}"
