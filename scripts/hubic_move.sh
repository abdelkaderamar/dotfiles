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
    echo "Move $hubic_dir to $local_dir ..."

    LOG=${BASE_LOG}-$(basename $local_dir).log

    
    $DO rclone move -v --stats 15s --transfers 2 \
	"$hubic_dir" "$local_dir" >> "$LOG" 2>&1
    res=$?
    if [ $res -ne 0 ]
    then
	sync_res=2
    fi

    if ( $OPT_SMS)
    then
	CMD="rclone move"
	send_sms $res "$CMD" "$1"
    fi
}

DO=''
OPT_SMS=false

dirs=()
while [ $# -gt 0 ]
do
  case "$1" in
    '-dry')  DO="echo" ;;
    '-sms')  OPT_SMS=true ;;
    *)  dirs+=($1)
	;;
  esac
  shift
done

sync_res=0

for dir in "${dirs[@]}"
do
    move_hubic_dir "$dir"
done

exit $sync_res

