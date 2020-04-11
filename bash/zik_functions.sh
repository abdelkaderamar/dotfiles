#! /bin/bash 

is_music_file() {
    ext="${1,,}"
    if [ $ext == "mp3" -o $ext == "flac" -o $ext == "m4a" -o $ext == "wma" ]
    then
	return 0
    fi
    return 1
}

is_cover_file() {
    ext="${1,,}"
    if [ "$ext" == "jpg" -o "$ext" == "bmp" -o "$ext" == "png" ]
    then
	return 0
    fi
    return 1
}

is_video_file() {
    ext="${1,,}"
    if [ "$ext" == "mp4" -o "$ext" == "avi" -o "$ext" == "m4v" ]
    then
	return 0
    fi
    return 1
}

read_artists() {
    data_file="$1"
    
    if [ -f "$data_file" ]
    then
	readarray -t artists < "$data_file"
    else
	artists=()
    fi
}

