#! /bin/bash -u

source $HOME/.bash_logging

interactive=false
process_dirs=false
process_files=false

special_dirs=(OST Singles VA World Compilation Arabic Instrumental Classical Misc)

dirs_to_ignore=()

usage() {
    e_header "$@"
    echo
    e_header "Usage $(basename $0) -d <dir>"
}

directory_not_set()
{
    e_error "Directory not set"
    exit 1
}

read_artists() {
    data_file="$1"
    
    #TODO: check file exists

    readarray -t artists < "$data_file"
}

read_dirs_to_ignore() {
    data_file="$1"
    
    #TODO: check file exists

    readarray -t dirs_to_ignore < "$data_file"
}

ask_to_add() {
    artist_dir="$1"
    e_arrow -n "Do you want to add [$artist_dir] to artists file (y/n) "
    read answer
    if [ $answer != "y" ]
    then
	return
    fi
    echo "$artist_dir" >> "$data_file"
}

check_artist_dir() {
    artist_dir=$1
    if [[ " ${artists[@]} " =~ " ${artist_dir} " ]]
    then
	artists_known+=( "$artist_dir" )
    elif [[ " ${special_dirs[@]} " =~ " ${artist_dir} " ]]
    then
	return
    else
	if ( $interactive )
	then
	    ask_to_add "$artist_dir"
	fi
	artists_unknown+=( "$artist_dir" )
    fi
}

is_music_file() {
    ext="${1,,}"
    if [ $ext == "mp3" -o $ext == "flac" -o $ext == "m4a" -o $ext == "wma" ]
    then
	return 0
    fi
    return 1
}

rename_file() {
    filename="$1"
    newfilename="$2"
    file_path="$3"
    tag="$4"
    file_dir=$(dirname "$file_path")
    newfile_path="$file_dir"/"$newfilename"
    e_arrow Renaming [$tag] from "$file_path" to "$newfile_path"
    mv -i "$file_path"  "$newfile_path"
}

process_file() {
    echo "# FILE [$1]"
#    return 0
    
    fullfilename="$1"
    filename=$(basename -- "$fullfilename")
    extension="${filename##*.}"
    name="${filename%.*}"

    filename_regex="^[0-9]{2} - (.*)$"
    newfilename=""
    if ( is_music_file $extension )
    then
	if [[ "$filename" =~ $filename_regex ]]
	then
	    e_arrow "$filename wellformed"
	elif [[ "$filename" =~ (^([0-9]{2}) ([a-Z].*)$) ]]
	then
	    newfilename="${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}"
	    rename_file "$filename" "$newfilename" "$fullfilename" 01
	elif [[ "$filename" =~ (^([0-9])[ ]+([a-Z].*)$) ]]
	then
	    newfilename="0${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}"
	    rename_file "$filename" "$newfilename" "$fullfilename" 02
	elif [[ "$filename" =~ (^([0-9])\.[ ]+([a-Z].*)$) ]]
	then
	    newfilename="0${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}"
	    rename_file "$filename" "$newfilename" "$fullfilename" 03
	elif [[ "$filename" =~ (^([0-9])-[ ]+([a-Z].*)$) ]]
	then
	    newfilename="0${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}"
	    rename_file "$filename" "$newfilename" "$fullfilename" 04	    
	elif [[ "$filename" =~ (^([0-9]) - ([a-Z].*)$) ]]
	then
	    newfilename="0${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}"
	    rename_file "$filename" "$newfilename" "$fullfilename" 05
	elif [[ "$filename" =~ (^([0-9]{2})\.[ ]+([a-Z].*)$) ]]
	then
	    newfilename="${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}"
	    rename_file "$filename" "$newfilename" "$fullfilename" 06	    
	elif [[ "$filename" =~ (^([0-9]{2})-([a-Z].*)$) ]]
	then
	    newfilename="${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}"
	    rename_file "$filename" "$newfilename" "$fullfilename" 07
	elif [[ "$filename" =~ (^([0-9]{2})\.([a-Z].*)$) ]]
	then
	    newfilename="${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}"
	    rename_file "$filename" "$newfilename" "$fullfilename" 08
	elif [[ "$filename" =~ (^\[([0-9]{2})\][ ]+([a-Z].*)$) ]]
	then
	    newfilename="${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}"
	    rename_file "$filename" "$newfilename" "$fullfilename" 09
	elif [[ "$filename" =~ (^\(([0-9]{2})\)[ ]+([a-Z].*)$) ]]
	then
	    newfilename="${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}"
	    rename_file "$filename" "$newfilename" "$fullfilename" 10
	elif [[ "$filename" =~ (^([0-9]{2})[ ]+([a-Z].*)$) ]]
	then
	    newfilename="${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}"
	    rename_file "$filename" "$newfilename" "$fullfilename" 11
	elif [[ "$filename" =~ (^${artist}[ ]*-[ ]*([0-9]{2})[ ]*-[ ]*([a-Z].*)$) ]]
	then
	    newfilename="${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}"
	    rename_file "$filename" "$newfilename" "$fullfilename" 12
	elif [[ "$filename" =~ (^[1-9]-([0-9]{2})[ ]+([a-Z].*)$) ]]
	then
	    newfilename="${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}"
	    rename_file "$filename" "$newfilename" "$fullfilename" 13	    
	elif [[ "$filename" =~ (^([0-9]{2})\._([a-Z].*)$) ]]
	then
	    newfilename="${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}"
	    rename_file "$filename" "$newfilename" "$fullfilename" 14
	elif [[ "$filename" =~ (^([0-9]{2})_([a-Z].*)$) ]]
	then
	    newfilename="${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}"
	    rename_file "$filename" "$newfilename" "$fullfilename" 15
	elif [[ "$filename" =~ (^([0-9]{2})-[ ]*([a-Z].*)$) ]]
	then
	    newfilename="${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}"
	    rename_file "$filename" "$newfilename" "$fullfilename" 07
	else
	    file_dir=$(dirname "$fullfilename")
	    e_warn "Unknown format $filename dir=[$file_dir]"
	fi
    fi # end if ( is_music_file
}

process_album() {
    album_path="$1"
    artist="$2"
    
    e_header "Process album $album_path"

    album_content=$(mktemp)
    find "$album_path" -maxdepth 1 -mindepth 1 > "$album_content"
    while read f
    do
	if [ -f "$f" ]
	then
	    process_file "$f" "$artist"
	elif [ -d "$f" ]
	then
	    process_album "$f" "$artist"
	fi
    done < "$album_content"

    rm -f "$album_content"
}

# Special dirs (prefixed with artist name) :
#   - EPs, Singles, Bootlegs, Lives, Specials, The Best Of, The Best Songs, Anthologie
#  
process_artist_dir() {
    artist="$1"
    artist_dir_path="$dir/$artist"
    #echo "Artist path $artist_dir_path"
    find "$artist_dir_path" -maxdepth 1 -mindepth 1 -type d > "$temp_file"
    while read d 
    do
	album_name=$(basename "$d")
	#echo "Checking subdir [$album_name]"
	regexp="$artist - ([12][0-9][0-9][0-9]) - (.*)"
	regexp2="$artist - ([12][0-9]{3}-[12][0-9]{3}) - (.*)"
	#echo "$regexp vs $album_name"
	if [[ "$album_name" =~ $regexp ]]
	then
	    if ( $process_files )
	    then
		process_album "$d" "$artist"
	    fi
	elif [[ "$album_name" =~ $regexp2 ]]
	then
	    if ( $process_files )
	    then
		process_album "$d" "$artist"
	    fi
	elif [ "$album_name" = "$artist - Lives" -o \
			     "$album_name" = "$artist - Bootlegs" -o \
			     "$album_name" = "$artist - Specials" -o \
			     "$album_name" = "$artist - Singles" -o \
			     "$album_name" = "$artist - EPs" -o \
			     "$album_name" = "$artist - The Best Of"  -o \
			     "$album_name" = "$artist - The Best Songs" -o \
	     		     "$album_name" = "$artist - Anthologie" ]
	then
	    if ( $process_files )
	    then
		process_album "$d" "$artist"
	    fi
	elif [[ "$album_name" =~ (^$artist #[0-9]{2}# (.*)$)  ]]
	then
	    if ( $process_files )
	    then
		process_album "$d" "$artist"
	    fi	    
	elif [[ "$album_name" =~ (^Tribute To $artist$)  ]]
	then
	    if ( $process_files )
	    then
		process_album "$d" "$artist"
	    fi	    
	elif [ "$album_name" != "Photos" ]
	then
	    malformed_dirs+=( "$artist_dir_path/$album_name" )
	fi
    done < "$temp_file"
}

dir=''
artists=()
artists_known=()
artists_unknown=()

while [ $# -ne 0 ]
do
    case "$1" in
	'-d')
	    shift
	    if [ $# -lt 1 ]; then directory_not_set; fi
	    dir=$1
	    ;;
	'-i')
	    interactive=true
	    ;;
	'-f')
	    process_files=true
	    ;;
	'-a')
	    process_dirs=true
	    ;;
    esac
    shift
done

if [ -z "$dir" ]
then
    directory_not_set
fi

# read artists file
read_artists $HOME/share/data/zik/artists.lst

read_dirs_to_ignore $HOME/share/data/zik/dirs_to_ignore.lst

printf '%s; ' "${artists[@]}"
echo

# check first level (directories are base on artist name)
temp_file=$(mktemp)
find "$dir" -maxdepth 1 -mindepth 1 -type d > "$temp_file"
subdirs=()
while read l
do
    subdirs+=( "$l" )
done < "$temp_file"

rm -f "$temp_file"

for d in "${subdirs[@]}"
do
    #echo "[$d]"
    base_dir=$(basename "$d")
    check_artist_dir "$base_dir"
done

e_header "${#artists_known[@]} known artists"

e_header "${#artists_unknown[@]} unknown artists"

for a in "${artists_unknown[@]}"
do
    e_warn "Unknown artist [$a]"
done


# foreach artist dir: check the content is album
IFS=$'\n'
sorted=($(sort <<<"${artists_known[*]}"))
unset IFS
artists_known=( "${sorted[@]}" )

malformed_dirs=()
for a in "${artists_known[@]}"
do
    if ( $process_dirs )
    then
	if [[ " ${dirs_to_ignore[@]} " =~ " ${a} " ]]
	then
	    e_arrow "Artist ${a} already processed"
            continue
	fi

	process_artist_dir "$a"
    fi
done

for d in "${malformed_dirs[@]}"
do
    e_warn "$d" malformed.
done

e_header "${#malformed_dirs[@]} malformed album dirname"

