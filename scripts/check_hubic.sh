#! /bin/bash -u

usage()
{
    echo "Usage"
    echo "    `basename $0` <dir>"
}


if [ $# -lt 1 ]
then
    usage
    exit 1
fi


check_hubic_activity()
{
    ls "$dir"/hubic_move.sh-*.log | while read f  
    do
	timestamp=$(stat -c%Z "$f")
	if [ $timestamp -ge $last_check ]
	then
	    echo checking "$f"

	    name=$(basename "$f")
	    name=${name%.log}
	    name=${name#hubic_move.sh-}
	    
	    msg=$(grep '^Transferred:' "$f" | tail -2)
	    error_msg=$(grep 'Attempt ./. failed with ' "$f"  | sed 's|.*Attempt ./. failed with \(.* errors\).*|\1|' | tail -1)
	    
	    MSG_TO_SEND="Hubic Status ${name}/${host}."$'\n'
	    MSG_TO_SEND+="${msg}. ${error_msg}"

	    echo "${MSG_TO_SEND}"

	    MSG_TO_SEND=$(echo ${MSG_TO_SEND} | tr '\n' '. ')
	    
	    sms.sh "${MSG_TO_SEND}"
	fi
    done
}

dir='.'
start_hour=9
end_hour=21
delay=3600

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
    '-delay') shift
	      delay=$1
	      ;;
    -*)  echo "Unknwon option $1"
	 ;;
    *)  dir="$1"
	;;
  esac
  shift
done

host=$(hostname)
last_check=$(date +%s)

while (true)
do
    current_hour=$(date +'%H')

    if [ $current_hour -ge $start_hour -a $current_hour -lt $end_hour ]
    then
        check_hubic_activity
	last_check=$(date +%s)
    fi
    
    sleep $delay
done
