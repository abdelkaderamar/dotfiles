#! /bin/bash -u


source $HOME/.bash_logging

## Usage

usage() {
    if [ $# -gt 0 ]
    then
	e_header "$@"
	echo
    fi
    e_header "Usage $(basename $0) -i <input video> [-o <output video>]"
}

## Check file exists and readable
check_file_exist() {
    file="$1"
    if [ -f "$file" ]
    then
	return 0
    fi
    return 1
}

input_video=''
output_video=''
volume_factor="2.000000"

warning=false
interactive=true

while [ $# -gt 0 ]
do
    case "$1" in
	'-i') shift
	      if [ $# -gt 0 ]; then input_video="$1"; fi
	      ;;
	'-o') shift
	      if [ $# -gt 0 ]; then output_video="$1"; fi
	      ;;
	"-vol") shift
		if [ $# -gt 0 ]; then volume_factor="$1"; fi
		;;
	'-np')
	    interactive=false
	    ;;
	*)
	    e_warn "Unknown option/parameter [$1]"
	    warning=true
	    ;;
    esac
    shift
done

if [ -z "$input_video" ]
then
    usage "Please provide input video"
    exit 1
fi

if [ -z "$output_video" ]
then
    filename=$(basename -- "$input_video")
    extension="${filename##*.}"
    name="${filename%.*}"
    output_video="${name}-bis.${extension}"

fi

check_file_exist "$input_video" || (e_error "[$input_video] doesn't exist"; exit 2)

check_file_exist "$output_video" && (e_error "[$output_video] exists already"; exit 2)

e_arrow "Input video:  $input_video"
e_arrow "Output video: $output_video"


answer=y
if ( $interactive || $warning )
then
    echo "Do you confirm (y/n) ? "
    read answer
fi

if [ "$answer" != "y" ]
then
    exit 3
fi

ffmpeg -i "$input_video" -vcodec copy -filter:a "volume=$volume_factor" "$output_video"

