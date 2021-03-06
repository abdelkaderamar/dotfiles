#! /bin/bash -u

source $HOME/.bash_logging
source $HOME/.zik_functions

## Usage
usage() {
    e_header "Usage $(basename $0) <dir1> <dir2> ...."
    echo
    e_arrow  " replace special charcter – -"
    e_arrow  " rename  '01 filename' ➜ '01 - filename"
    e_arrow  " rename  '01. filename' ➜ '01 - filename"
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


replace_special_character() {
    char="$1"
    new_char="$2"
    dir="$3"

    temp_file=$(mktemp)
    find "$dir" -name "*${char}*" > "$temp_file"

    while read f
    do
	new_filename=$(echo "$f" | sed "s/${char}/${new_char}/g")
        mv -vi "$f" "$new_filename"
    done < "$temp_file"
    rm -f "$temp_file"
    
}

process_dir() {
    album_path="$1"
    e_header "Process directory $album_path"

    album_content=$(mktemp)
    find "$album_path" -maxdepth 1 -mindepth 1 > "$album_content"
    while read f
    do
	if [ -f "$f" ]
	then
	    process_file "$f"
	else
	    e_warn "Ignore [$f]"
	fi
    done < "$album_content"

    rm -f "$album_content"
}


for d in "$@"
do
    # replace_special_character – - "$1"
    process_dir "$d"
done

    
    
