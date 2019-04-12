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
    
