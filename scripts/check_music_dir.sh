#! /bin/bash -u

interactive=false
special_dirs=(OST Singles VA World Compilation Arabic Instrumental Classical Misc)
usage() {
    echo "$@"
    echo
    echo "Usage $(basename $0) -d <dir>"
}

directory_not_set()
{
    usage "Directory not set"
    exit 1
}

read_artists() {
    data_file="$1"
    
    #TODO: check file exists

    readarray -t artists < "$data_file"
}

ask_to_add() {
    artist_dir="$1"
    echo -n "Do you want to add [$artist_dir] to artists file (y/n) "
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

process_file() {
    fullfilename="$1"
    filename=$(basename -- "$fullfilename")
    extension="${filename##*.}"
    name="${filename%.*}"

    filename_regex="^[0-9]{2} - (.*)$"
    if ( is_music_file $extension )
    then
	if [[ "$filename" =~ $filename_regex ]]
	then
	    echo "$filename wellformed"
	elif [[ "$filename" =~ (^([0-9]{2}) ([a-Z].*)$) ]]
	then
	    echo "RENAME01 [$filename] TO [${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}]"
	elif [[ "$filename" =~ (^([0-9])[ ]+([a-Z].*)$) ]]
	then
	    echo "RENAME02 [$filename] TO [0${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}]"
	elif [[ "$filename" =~ (^([0-9])\.[ ]+([a-Z].*)$) ]]
	then
	    echo "RENAME03 [$filename] TO [0${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}]"
	elif [[ "$filename" =~ (^([0-9])-[ ]+([a-Z].*)$) ]]
	then
	    echo "RENAME04 [$filename] TO [0${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}]"
	elif [[ "$filename" =~ (^([0-9]) - ([a-Z].*)$) ]]
	then
	    echo "RENAME05 [$filename] TO [0${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}]"
	elif [[ "$filename" =~ (^([0-9]{2})\.[ ]+([a-Z].*)$) ]]
	then
	    echo "RENAME06 [$filename] TO [${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}]"
	elif [[ "$filename" =~ (^([0-9]{2})-([a-Z].*)$) ]]
	then
	    echo "RENAME07 [$filename] TO [${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}]"
	elif [[ "$filename" =~ (^([0-9]{2})\.([a-Z].*)$) ]]
	then
	    echo "RENAME08 [$filename] TO [${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}]"
	elif [[ "$filename" =~ (^\[([0-9]{2})\][ ]+([a-Z].*)$) ]]
	then
	    echo "RENAME09 [$filename] TO [${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}]"
	elif [[ "$filename" =~ (^\(([0-9]{2})\)[ ]+([a-Z].*)$) ]]
	then
	    echo "RENAME10 [$filename] TO [${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}]"
	elif [[ "$filename" =~ (^([0-9]{2})[ ]+([a-Z].*)$) ]]
	then
	    echo "RENAME11 [$filename] TO [${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}]"
	elif [[ "$filename" =~ (^${artist}[ ]*-[ ]*([0-9]{2})[ ]*-[ ]*([a-Z].*)$) ]]
	then
	    echo "RENAME12 [$filename] TO [${BASH_REMATCH[2]} - ${BASH_REMATCH[3]}]"
	else
	    echo "Unknown format $filename"
	fi
	    
    fi
}

process_album() {
    album_path="$1"
    artist="$2"
    
    echo "Process album $album_path"

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
	    process_album "$d" "$artist"
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

echo "${#artists_known[@]} known artists"

echo "${#artists_unknown[@]} unknown artists"

for a in "${artists_unknown[@]}"
do
    echo "[$a]"
done


# foreach artist dir: check the content is album
IFS=$'\n'
sorted=($(sort <<<"${artists_known[*]}"))
unset IFS
artists_known=( "${sorted[@]}" )

malformed_dirs=()
for a in "${artists_known[@]}"
do
    process_artist_dir "$a"
#    read l
done
# find unwanted file (.url
