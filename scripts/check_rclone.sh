#! /bin/bash -u

start_hour=9
end_hour=22

while [ $# -gt 0 ]
do
  case "$1" in
    '-dry')  DO="echo" ;;
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

while true
do
    sleep 1800
    
    pidof rclone
    res=$?

    if [ $res -eq 0 ]
    then
	continue
    fi
    
    if [ $res -ne 0 ]
    then
	MSG="Rclone is not running on $(hostname)."

	# check if we can connect to hubic
	rclone lsd hubic:default
	res=$?

	if [ $res -ne 0 ]
	then
	    MSG+=" Rclone is not connected on $(hostname)"
	fi

	echo $MSG
	
	current_hour=$(date +'%H')

	if [ $current_hour -ge $start_hour -a $current_hour -lt $end_hour ]
	then
	    sms.sh "$MSG"
	fi
	
	continue
    fi
done
