#! /bin/bash -u

SYNC_DRIVE='/media/amar/HD2/Sync'
MV_DRIVE='/media/amar/WD 1TO/Moved'

DIR=$1

SYNC_DIR="$SYNC_DRIVE/$DIR"
MV_DIR="$MV_DRIVE/$DIR"

[[ -d $SYNC_DIR ]] || (echo "Missing sync dir $SYNC_DIR"; exit 1)
[[ -d $MV_DIR ]] || (echo "Missing move dir $MV_DIR"; exit 1)

find "$SYNC_DIR" -type f > sync_drive_files.list

cat sync_drive_files.list | while read sync_file
do
    mv_file=${sync_file#$SYNC_DIR}
    mv_file=${MV_DIR}/${mv_file#/}
    
    if [ ! -f "$mv_file" ]
    then
	   echo missing "$sync_file" >> missing_files.list; 
	   continue
   fi

    echo -n "Comparing $sync_file vs $mv_file ... "  >> clean_hubic_hdd.log
    cmp --quiet "$sync_file" "$mv_file"
    res=$?
    echo "$res" >> clean_hubic_hdd.log
    
    if [ $res -eq 0 ]
    then
	echo "Removing $sync_file" >> removed_files.log
	rm -f "$sync_file"
    fi
done

echo "..." >> clean_hubic_hdd.log
echo "Done at $(date)" >> clean_hubic_hdd.log

