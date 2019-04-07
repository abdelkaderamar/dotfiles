#! /bin/bash -u

while true
do
    sleep 1800
    
    pidof rclone
    res=$?

    if [ $res -ne 0 ]
    then
	sms.sh "Rclone is not running on $(hostname)"
	continue
    fi

    rclone lsd hubic:default
    res=$?

    if [ $res -ne 0 ]
    then
	sms.sh "Rclone is not connected on $(hostname)"
	continue
    fi

done
