#! /bin/bash -u

source $HOME/.bash_logging

interactive=false
process_dirs=false
process_files=false

special_dirs=(OST Singles VA World Compilation Arabic Instrumental Classical Misc)

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
	else
	    e_warn "Unknown format $filename"
	fi
	    
    fi
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
}

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
	#echo "$regexp vs $album_name"
	if [[ "$album_name" =~ $regexp ]]
	then
	    if ( $process_files )
	    then
		process_album "$d" "$artist"
	    fi
	else
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
	process_artist_dir "$a"
    fi
done

for d in "${malformed_dirs[@]}"
do
    e_warn "$d" malformed.
done

#TODO: find unwanted file (.url
