#! /bin/bash -u

source _hubic_common.sh

BASE_LOG=`basename $0`

usage()
{
    echo "Usage"
    echo "    `basename $0` {dirs}"
}


if [ $# -lt 1 ]
then
    usage
    exit 1
fi

rclone lsd hubic:default > /dev/null
res=$?

[[ $res -eq 0 ]] || (echo Not connected; exit 1)

move_hubic_dir()
{
    dir="$1"
    dir="${dir%/}"
    hubic_dir=hubic:default/Media/"$dir"
    local_dir="$dir"

    LOG=${BASE_LOG}-$(basename "$local_dir").log

    echo "Move $hubic_dir to $local_dir ..." >> "$LOG" 2>&1

    $DO rclone move -v --stats ${STAT}s --transfers $TRANSFER --retries $RETRY \
	"$hubic_dir" "$local_dir" >> "$LOG" 2>&1
    res=$?
    if [ $res -ne 0 ]
    then
	move_res=$res
    fi

    if ( $OPT_SMS)
    then
	current_hour=$(date +'%H')

	if [ $current_hour -ge $START_HOUR -a $current_hour -lt $END_HOUR ]
	then
	    CMD="rclone move"
	    $DO send_sms $res "$CMD" "$1" >> "$LOG" 2>&1
	fi
    fi
}

parse_arguments "$@"

move_res=0

for dir in "${dirs[@]}"
do
    move_hubic_dir "$dir"

    if [ $move_res -eq 0 ]
    then
	echo "SUCCESS"
    else
	echo "FAILED"
    fi
done

exit $move_res

