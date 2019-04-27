#! /bin/bash -u

send_sms()
{
    res=$1
    CMD="$2"
    ARGS="$3"
    
    if [ $res -eq 0 ]
    then
	STATUS="SUCCESS"
	verb="succeed"
    else
	STATUS="ERROR"
	verb="failed"
    fi
    HOSTNAME=$(hostname)
	
    MSG_TO_SEND="$STATUS. Command {$CMD} $verb at $(date) on host {$HOSTNAME}. Arguments=$ARGS"
	
    sms.sh "$MSG_TO_SEND"
    
}

parse_arguments()
{
    DO=''
    OPT_SMS=false

    dirs=()
    while [ $# -gt 0 ]
    do
	case "$1" in
	    '-dry')  DO="echo" ;;
	    '-sms')  OPT_SMS=true ;;
	    '-retry') shift
		      RETRY=$1
		      ;;
	    '-transfer') shift
			 TRANSFER=$1
			 ;;
	    '-stat') shift
		     STAT=$1
		     ;;
	    '-start')  shift
		       START_HOUR=$1
		       ;;
	    '-end')  shift
		     END_HOUR=$1
		     ;;
	    '-*') echo "Unknown option $1"
		  ;;
	    *)  dirs+=("$1")
		;;
	esac
	shift
    done
}

RETRY=3
TRANSFER=4
STAT=15
START_HOUR=9
END_HOUR=22
