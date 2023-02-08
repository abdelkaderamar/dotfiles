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
    if [ "$ext" == "jpg" -o "$ext" == "jpeg" -o "$ext" == "bmp" -o "$ext" == "png"  ]
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

is_booklet_file() {
    ext="${1,,}"
    if [ "$ext" == "pdf" ]
    then
	return 0
    fi
    return 1
}

is_lyric_file() {
    ext="${1,,}"
    if [ "$ext" == "lrc" ]
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

zik_get_bitrate() {
    local data_file="$1"

    if [ -f "$data_file" ]
    then
        local result=$(ffprobe -show_format "$data_file" 2>&1 | grep '^bit_rate' | sed 's/^bit_rate=\(.*\)/\1/')
        local result_in_kb=$((result/1000))
        e_arrow "bitreate of [$data_file] = $(tput bold)$((result/1000))KB$(tput sgr0) ($result)"
    else
        e_error "File [$data_file] not found"
    fi
}

