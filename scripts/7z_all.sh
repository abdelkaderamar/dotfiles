#! /bin/bash -u

shopt -s nullglob

CMD="nice 7z"
LOG=7z_all.log

###############################################################################

source uncompress_all_common.sh

###############################################################################

EXTRACT_DIR=.
if [ ! -z $SUFFIX ]
then
  EXTRACT_DIR=zip-$RANDOM
fi

for f in *.7z
do
  e_header "Processing file $f"
  $CMD x "$f"  -o"$EXTRACT_DIR" >> "$LOG"
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
