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


check_free_space()
{
    idx=$1
    dir="$2"
    free_space=`df -mP --total "$dir" | tail -1 | awk '{print $4}' | sed 's/%$//g'`
    free_space_readable=`df -hP --total "$dir" | tail -1 | awk '{print $4}' | sed 's/%$//g'`

    prev_free_space[$idx]=${curr_free_space[$idx]}
    curr_free_space[$idx]=$free_space

    prev=${prev_free_space[idx]}
    curr=${curr_free_space[idx]}
    
    curr_date=$(date +'%Y-%m-%d %H:%M')
    echo "$curr_date - Previous free space of [$dir] = $prev"
    echo "$curr_date - Current free space of  [$dir] = $curr"
    
    if [ $prev -ne 0 ]
    then
	used=$((prev-curr))

	init=${init_free_space[idx]}
	total_used=$((init-curr))
	
	echo "$curr_date - Used disk in [$dir] = $used"	
	MSG_TO_SEND="Used disk=[${used}M] in {$host}/{${dir}}. Total=[${total_used}M]"
	echo $MSG_TO_SEND
	sms.sh "$MSG_TO_SEND"
    else
	init_free_space[$idx]=$curr
	echo "Initial free space of [$dir] = ${init_free_space[idx]} M"
    fi
}

dirs=()
prev_free_space=()
curr_free_space=()
init_free_space=()
start_hour=9
end_hour=21
delay=1800

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
    *)  dirs+=("$1")
	curr_free_space+=(0)
	;;
  esac
  shift
done

host=$(hostname)

while (true)
do
    current_hour=$(date +'%H')

    if [ $current_hour -ge $start_hour -a $current_hour -lt $end_hour ]
    then
	for((i=0;i<${#dirs[@]};++i))
	do
            check_free_space $i "${dirs[i]}"
	done
    fi

    sleep $delay
done
