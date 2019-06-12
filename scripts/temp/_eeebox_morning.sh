#! /bin/bash -u


LOG=$(pwd)/eeebox_morning-$(date +'%Y-%m-%d')
ERR=$LOG.err
LOG=$LOG.log

echo "Cleaning directories ..." >> $LOG

cd $HOME
./_clean_hubic_hdd.sh Tv_Shows

echo "Done at $(date)" >> $LOG

echo >> $LOG

echo "Starting eeebox jobs ..." >> $LOG

./_eeebox_job.sh >> $LOG 2>> $ERR &


check_rclone.sh &
check_hosts.sh rasp &
monitor_hubic.sh -delay 1200 /home/amar/wd >> monitor_hubic.log 2>&1 &

#hd_monitor.sh -start 8 -end 23 "/media/amar/WD 1TO/" &
#check_hubic.sh -start 8 -end 23 "/media/amar/WD 1TO/Moved/" &

