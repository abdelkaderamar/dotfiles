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

sync_hubic_dir()
{
    hubic_dir=hubic:default/Media/"$1"
    local_dir="$1"

    LOG=${BASE_LOG}-$(basename $local_dir).log
    
    echo "Sync $hubic_dir in $local_dir ..."  >> "$LOG" 2>&1
    $DO rclone sync -v -P \
	--stats ${STAT}s --transfers $TRANSFER --retries $RETRY \
	"$hubic_dir" "$local_dir" >> "$LOG" 2>&1
    res=$?
    if [ $res -ne 0 ]
    then
	sync_res=$res
    fi
    
    if ( $OPT_SMS)
    then
	current_hour=$(date +'%H')

	if [ $current_hour -ge $START_HOUR -a $current_hour -lt $END_HOUR ]
	then
	    CMD="rclone sync"
	    $DO send_sms $res "$CMD" "$1" >> "$LOG" 2>&1
	fi
    fi
}

parse_arguments "$@"

sync_res=0


for dir in "${dirs[@]}"
do
    sync_hubic_dir "$dir"
done

