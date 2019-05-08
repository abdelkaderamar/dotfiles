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

send_summary_sms()
{
    sum=0
    while read l
    do
	i=$(echo $l |cut -f2 -d':');
	sum=$((i+sum));
    done < "$summary"

    if [ $prev_sum -eq 0 ]
    then
	prev_sum=$sum
    fi
    
    sms.sh "Hubic Summary : $sum ERRORS (prev sum = $prev_sum)"

    prev_sum=$sum
}

persist_data()
{
    cp /dev/null "$summary"
    
    for key in "${!errors_dico[@]}";
    do
	echo $key:${errors_dico[$key]} >> "$summary"
    done
}

monitor_hubic_activity()
{
    updated=false
    
    for f in $(ls "$dir"/hubic_move.sh-*.log)  
    do
	echo checking "$f"

	name=$(basename "$f")
	name=${name%.log}
	name=${name#hubic_move.sh-}
	
	error_count=$(grep 'Attempt ./.' "$f"  | \
			  tail -1 | \
			  sed 's|.*Attempt ./. failed with \(.*\) errors.*|\1|')

	echo $name $error_count

	if [ -z $error_count ]
	then
	    error_count=0
	fi
	    
	if [ ${errors_dico[$name]+_} ]
	then
	    prev=${errors_dico[$name]}
            echo "$name found => compare with previous value $prev"
	    if [ $prev -ne $error_count ]
	    then
		errors_dico[$name]=$error_count
		MSG_TO_SEND="Hubic Status: ${name} ${error_count} (Prev=${prev})"
	        sms.sh "$MSG_TO_SEND"
		updated=true
            else
                echo "--> No change"
	    fi
	else
            echo "$name not found"
	    errors_dico[$name]=$error_count
	    updated=true
	fi
    done

    if ( $updated )
    then
        echo "persisting data and sending summary"
	persist_data
	send_summary_sms
    fi
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
summary=hubic_summary.txt
prev_sum=0

declare -A errors_dico

if [ -f "$summary" ]
then
    while read l
    do
	n=$(echo "$l" | cut -f1 -d':')
	c=$(echo "$l" | cut -f2 -d':')
	errors_dico[$n]=$c
    done < "$summary"	
fi


while (true)
do
    current_hour=$(date +'%H')

    if [ $current_hour -ge $start_hour -a $current_hour -lt $end_hour ]
    then
	monitor_hubic_activity
    fi
    
    sleep $delay
done
