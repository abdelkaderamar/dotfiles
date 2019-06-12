#! /bin/bash -u



LOG=$(pwd)/eeebox-job.log
ERR=${LOG%.log}.err

cd '/media/amar/WD 1TO/Moved'

if [ $? -ne 0 ]
then
    echo failed to move to directory >> "$ERR"
    exit 1
fi

get_dirs()
{
    dirs=(Comics Audio_Books)
    dir_count=${#dirs[@]}
    

    ls -t /media/amar/HD2/Sync/Tv_Shows/ > tvshow.list

    while read show
    do
	dirs[$dir_count]="Tv_Shows/$show"
	dir_count=$((dir_count+1))
    done < tvshow.list

    echo "Directories to move are:"  >> "$LOG"
    for dir in "${dirs[@]}"
    do
	echo "  - $dir " >> "$LOG"
    done
}

########################################################################
### ARGUMENTS
########################################################################
DO=""
ONCE=false
RETRY=1
while [ $# -gt 0 ]
do
  case "$1" in
    '-dry')  DO="echo" ;;
    '-once') ONCE=true ;;
    '-retry') shift
	      RETRY=$1
	      ;;
  esac
  shift
done
########################################################################



while true
do
    get_dirs
    
    echo "Starting ..." >> "$LOG"

    echo "Checking rclone ..."  >> "$LOG"
    res=1
    for((i=1;i<=5;++i))
    do
      $DO rclone lsd hubic:default/Media  >> "$LOG"
      if [ $? -eq 0 ]
      then
	echo "Rclone is connected to hubic"  >> "$LOG"
        res=0
        break
      fi
      sleep 30
    done

    if [ $res -ne 0 ]
    then
	echo "Error. Rclone not connected $(hostname)" >> "$ERR"
	$DO sms.sh "Error. Rclone not connected $(hostname)"
	exit 1
    fi

    
    for i in "${dirs[@]}" 
    do
	echo Running hubic_move.sh on ["$i"] >> "$LOG"

	$DO hubic_move.sh -retry $RETRY "$i" >> "$LOG"

	res=$?
	
	if [ $res -eq 0 ]
	then
	    STATUS="SUCCESS"
	    verb="succeed"
	    HOSTNAME=$(hostname)

	    MSG_TO_SEND="$STATUS. hubic_move $verb for $i on $HOSTNAME. Time = $(date)"

	    $DO sms.sh "$MSG_TO_SEND"  >> "$LOG"

	fi
    done

    
    echo "Finishing a cycle"  >> "$LOG"

    sleep 10
    
done
