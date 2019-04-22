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
	fi
    done
    
#    if [ $prev -ne 0 ]
#    then
#	used=$((prev-curr))
#
#	init=${init_free_space[idx]}
#	total_used=$((init-curr))
#	
#	echo "$curr_date - Used disk in [$dir] = $used"	
#	MSG_TO_SEND="Used disk={${used}M} in {$host}/{${dir}}. Total={${total_used}M}"
#	echo $MSG_TO_SEND
#	sms.sh "$MSG_TO_SEND"
#    else
#	init_free_space[$idx]=$curr
#	echo "Initial free space of [$dir] = ${init_free_space[idx]} M"
#    fi
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
    fi

    last_check=$(date +%s)
    
    sleep $delay
done
