#! /bin/bash -u

shopt -s nullglob

CMD="nice unzip"
LOG=unzip_all.log

###############################################################################

source uncompress_all_common.sh

###############################################################################

EXTRACT_DIR=.
if [ ! -z $SUFFIX ]
then
  EXTRACT_DIR=zip-$RANDOM
fi

for f in *.zip
do
  e_header "Processing file $f"
  $CMD "$f" -d "$EXTRACT_DIR" >> "$LOG"
  res=$?
  if [ ! -z $SUFFIX ]
  then
    add_suffix "$SUFFIX" "$EXTRACT_DIR"
    mv "$EXTRACT_DIR"/* .
    rmdir "$EXTRACT_DIR"
  fi
  post_uncompress $res "${f}"
done

terminate_uncompress
