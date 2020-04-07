#! /bin/bash -u

source $HOME/.bash_logging
source zik_functions.sh

## Usage

usage() {
    if [ $# -gt 0 ]
    then
	e_header "$@"
	echo
    fi
    e_header "Usage $(basename $0) -d <dir> -z <zik dir>"
}

##
process_album_content()
{
    artist="$1"
    album="$2"
    
    readarray -d '' dir_content < <(find "$album" -maxdepth 1 -mindepth 1 -print0)
    for f in "${dir_content[@]}"
    do
	echo "Checking $f"
	#TODO: to complete
    done
}

process_album_dir() {
    artist="$1"
    album="$2"

    album_name=$(basename "$album")
    regexp="$artist - ([12][0-9][0-9][0-9]) - (.*)"
    regexp2="$artist - ([12][0-9]{3}-[12][0-9]{3}) - (.*)"

    if [[ "$album_name" =~ $regexp || \
	      "$album_name" =~ $regexp2 || \
	      "$album_name" =~ "(^$artist #[0-9]{2}# (.*)$)"  ]]
    then
	:
	echo "=> Correct format"
	process_album_content "$artist" "$album"
    else
	e_error "Unknown format $album"
    fi
}

dir=''
artist=''
album=''
while [ $# -gt 0 ]
do
    case "$1" in
	'-d') shift
	      if [ $# -gt 0 ]; then dir="$1"; fi
	      ;;
	'-a') shift
	      if [ $# -gt 0 ]; then artist="$1"; fi
	      ;;
	'-z') shift
	     if [ $# -gt 0 ]; then album="$1"; fi
	     ;;
    esac
    shift
done
		      
if [ -z "$dir" -o -z "$album" -o -z "artist" ]
then
    usage "Syntax error"
    exit 1
fi

#TODO: check artist is known and its directory exists
#TODO: If unknown or the directory of the artists doesn't exist => ask to create it


process_album_dir "$artist" "$album"

