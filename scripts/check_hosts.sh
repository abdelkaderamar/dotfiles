#! /bin/bash -u

usage()
{
    echo Usage
    echo "   "`basename $0` {hosts}
}

if [ $# -lt 1 ]
then
    usage
    exit 1
fi

start_hour=9
end_hour=21

hosts=()
while [ $# -gt 0 ]
do
  case "$1" in
      '-start')  shift
		 start_hour=$1
		 ;;
      '-end')  shift
	       end_hour=$1
	       ;;
      -*)  echo "Unknwon option $1"
	     ;;
      *)  hosts+=($1)
	;;
  esac
  shift
done


while true
do
    current_hour=$(date +'%H')

    if [ $current_hour -ge $start_hour -a $current_hour -lt $end_hour ]
    then
	for host in  "${hosts[@]}"
	do
	    ssh "$host" "ls > /dev/null"
	    res=$?
	    
	    if [ $res -ne 0 ]
	    then
		sms.sh "The host $host is unreachable"
	    fi
	done
    fi
    
    sleep 1800
    
done
