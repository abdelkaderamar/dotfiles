#! /bin/bash -u

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

check_free_space()
{
    free_space=`df -mP --total "$1" | tail -1 | awk '{print $4}' | sed 's/%$//g'`
    free_space_readable=`df -hP --total "$1" | tail -1 | awk '{print $4}' | sed 's/%$//g'`
    
    if [ $free_space -lt 7000 ]
    then
	MSG_TO_SEND="Low free space in {$host}. Free=$free_space_readable"
	echo $MSG_TO_SEND
	sms.sh "$MSG_TO_SEND"
    fi
}

dirs=()
start_hour=9
end_hour=21

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

host=$(hostname)

while (true)
do
    current_hour=$(date +'%H')

    if [ $current_hour -ge $start_hour -a $current_hour -lt $end_hour ]
    then
	for dir in "${dirs[@]}"
	do
            check_free_space "$dir"
	done
    fi

    sleep 1800
done
