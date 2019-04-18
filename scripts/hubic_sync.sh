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
    
    echo "Sync $hubic_dir in $local_dir ..."
    $DO rclone sync -v --stats 15s \
	"$hubic_dir" "$local_dir" >> "$LOG" 2>&1
    res=$?
    if [ $res -ne 0 ]
    then
	sync_res=2
    fi
    
    if ( $OPT_SMS)
    then
	current_hour=$(date +'%H')

	if [ $current_hour -ge $start_hour -a $current_hour -lt $end_hour ]
	then
	    CMD="rclone sync"
	    send_sms $res "$CMD" "$1"
	fi
    fi
}

DO=''
OPT_SMS=false

dirs=()
start_hour=9
end_hour=22

while [ $# -gt 0 ]
do
  case "$1" in
    '-dry')  DO="echo" ;;
    '-sms')  OPT_SMS=true ;;
    '-start')  shift
	       start_hour=$1
	       ;;
    '-end')  shift
	     end_hour=$1
	     ;;
    -*)  echo "Unknwon option $1"
	 ;;
    *)  dirs+=($1)
	;;
  esac
  shift
done

sync_res=0


for dir in "${dirs[@]}"
do
    sync_hubic_dir "$dir"
done

