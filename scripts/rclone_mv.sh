#!/bin/bash -u

do_upload()
{
  DIR="$1"
  DIR="${DIR%/}"
  LOG="$SERVICE"-"$DIR"
  d=$(date +'%Y-%m-%d')
  LOG=$LOG-$d.log
  REMOTE="$BASE_DIR"/"$DIR"

   echo uploading $DIR to $REMOTE ... >> upload.log

   rclone move -v --stats 15s --transfers 2 "$DIR" "$REMOTE" >> "$LOG" 2>&1

   echo "done with error code $?" >> upload.log
   echo >> upload.log
}

function usage()
{
  echo "Usage"
  echo "    basename $0 service base_dir {dirs|files}"
}

if [ $1 = "-h" -o "$1" = "--help" ]
then
  usage
  exit 0
fi

if [ $# -lt 3 ]
then
  usage
  exit 1
fi

SERVICE="$1"
shift
BASE_DIR="$SERVICE":"$1"
shift

for dir in "$@"
do
  do_upload "$dir"
done
