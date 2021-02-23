#! /bin/bash -u

source $HOME/.bash_logging
source $HOME/.zik_functions

## Usage

usage() {
    if [ $# -gt 0 ]
    then
	e_header "$@"
	echo
    fi
    e_header "Usage $(basename $0) -d <dir> -z <zik dir> [-a <artist>]"
    e_arrow  "   <dir>       Music repository"
    e_arrow  "   <zik dir>   Album directory"
    echo
    e_header "Help:"
    e_arrow  "   ZIK_DRIVE : environment variable to set automatically music repository directory"
    e_arrow  "   Data file of artists is stored here $HOME/share/data/zik/artists.lst" 
    e_arrow  "   Album directory name pattern is [Artist] - [Year] - [Album title]"
    e_arrow  "   If not provided, artist name can be automatically deduced from album directory"
}

process_file() {
#    echo "# FILE [$1]"
#    return 0
    
    local fullfilename="$1"
    local filename=$(basename -- "$fullfilename")
    local extension="${filename##*.}"
    local name="${filename%.*}"

    local filename_regex="^[0-9]{2} - (.*)$"
    local newfilename=""
    
    if ( is_music_file $extension )
    then
	if [[ "$filename" =~ $filename_regex ]]
	then
	    e_success "$filename wellformed"
	else
	    file_dir=$(dirname "$fullfilename")
	    e_error "Unknown format $filename dir=[$file_dir]"
	    album_valid=false
	fi
    elif ( is_cover_file "$extension")
    then
	e_success "Cover file [$filename]"
    elif ( is_video_file "$extension")
    then
	e_success "Video file [$filename]"
    elif ( is_booklet_file "$extension")
    then
	e_success "Booklet file [$filename]"
    else
	file_dir=$(dirname "$fullfilename")
	e_error "Unknown file type [$filename] dir=[$file_dir]"
	album_valid=false
    fi # end if ( is_music_file
}

##
process_album_content()
{
    local artist="$1"
    local album="$2"
    
    readarray -d '' dir_content < <(find "$album" -maxdepth 1 -mindepth 1 -print0)
    for f in "${dir_content[@]}"
    do
	#echo "Checking $f"

	if [ -f "$f" ]
	then
	    process_file "$f" "$artist"
	elif [ -d "$f" ]
	then
	    process_album_content "$artist" "$f"
	fi

    done
}

check_artist() {
    read_artists $HOME/share/data/zik/artists.lst
    
    artist="$1"
    if [[ " ${artists[@]} " =~ " ${artist} " ]]
    then
	e_arrow "Artist found [$artist]"
    else
        e_error "Artist [$artist] not found"
	album_valid=false
	exit 3
    fi
}

process_album_dir() {
    local artist="$1"
    local album="$2"

    local album_name=$(basename "$album")
    local regexp="$artist - ([12][0-9][0-9][0-9]) - (.*)"
    local regexp2="$artist - ([12][0-9]{3}-[12][0-9]{3}) - (.*)"

    if [[ "$album_name" =~ $regexp || \
	      "$album_name" =~ $regexp2 || \
	      "$album_name" =~ "(^$artist #[0-9]{2}# (.*)$)"  ]]
    then
	e_success "Correct dir format"
	process_album_content "$artist" "$album"
    else
	e_error "Unknown format $album"
	album_valid=false
    fi
}

process_single_dir() {
    local artist="$1"
    local album="$2"

    local album_name=$(basename "$album")
    local regexp="$artist - Single - ([12][0-9][0-9][0-9]) - (.*)"

    if [[ "$album_name" =~ $regexp ]] 
    then
	e_success "Correct dir format"
	process_album_content "$artist" "$album"
    else
	e_error "Unknown format $album"
	album_valid=false
    fi
}

detect_artist() {
    local album_name="$1"
    local regexp1="^(.*) - ([12][0-9][0-9][0-9]) - (.*)"
    local regexp2="^(.*) - ([12][0-9]{3}-[12][0-9]{3}) - (.*)"
    
    if [[ "$album_name" =~ $regexp1 || \
	      "$album_name" =~ $regexp2 ]]
    then
	e_arrow "Is this the correct artist name [${BASH_REMATCH[1]}] ?"
	echo -n "y/n ? "
	read answer
	if [[ "$answer" == "y" || "$answer" == "yes" ]]
	then
	    artist="${BASH_REMATCH[1]}"
	fi
    fi
}

move_album() {
    e_arrow "Moving [$album] the album"
    dest="$dir/$artist"
    e_header "Moving [$album] to [$dest]. Do you confirm (yes/no) ? "
    read answer
    if [ "$answer" == "yes" ]
    then
	mkdir -p "$dest" 
	mv "$album" "$dir/$artist/"
    fi
}

move_single() {
    e_arrow "Moving the single [$album]"
    dest="$dir/$artist/$artist - Singles"
    e_header "Moving [$album] to [$dest]. Do you confirm (yes/no) ? "
    read answer
    if [ "$answer" == "yes" ]
    then
	mkdir -p "$dest" 
	mv "$album" "$dest/"
    fi
}

dir=''
artist=''
album=''

if [ ! -z "${ZIK_DRIVE+x}" ]
then
    dir="$ZIK_DRIVE"
fi

is_album=true
is_single=false

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
	'-single')
	    is_single=true
	    is_album=false
	    ;;
    esac
    shift
done


if [ -z "$dir" -o -z "$album" ]
then
    usage "Syntax error"
    exit 1
fi

[ ! -d "$album" ] &&  e_error "The dir [$album] was not found" && exit 2 
[ ! -d "$dir" ] &&  e_error "The dir [$dir] was not found" && exit 3 

if [ -z "$artist" -a $is_album ]
then
    detect_artist "$album"
fi

if [ -z "$artist" ]
then
    e_error "Artist not defined"
    usage "Syntax error"
    exit 1
fi


album_valid=true

check_artist "$artist"

if ( $is_album )
then
    process_album_dir "$artist" "$album"
    if ( $album_valid )
    then
	move_album
    else
	e_warn "The album [$album] cannot be moved"
    fi
fi

if ( $is_single )
then
    process_single_dir "$artist" "$album"
    if ( $album_valid )
    then
	move_single
    else
	e_warn "The single [$album] cannot be moved"
    fi
fi
