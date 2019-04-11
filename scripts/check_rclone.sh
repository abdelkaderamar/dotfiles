#! /bin/bash -u

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
	sms.sh "$MSG"
	continue
    fi
done
