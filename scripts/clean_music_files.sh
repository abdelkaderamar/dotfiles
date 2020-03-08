#! /bin/bash -u

usage() {
    :
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

replace_special_character – - "$1"

