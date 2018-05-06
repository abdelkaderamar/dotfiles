#! /bin/bash -u

shopt -s nullglob

CMD="nice unrar x"
LOG=unrar_all.log

###############################################################################

source uncompress_all_common.sh

###############################################################################

for f in *part001.rar
do
  e_header "Processing file $f"
  $CMD "$f" >> "$LOG"
  post_uncompress $? "${f%001.rar}"???.rar
done

for f in *part01.rar
do
  e_header "Processing file $f"
  $CMD "$f" >> "$LOG"
  post_uncompress $? "${f%01.rar}"??.rar
done

for f in *part1.rar
do
  e_header "Processing file $f"
  $CMD "$f" >> "$LOG"
  post_uncompress $? "${f%1.rar}"?.rar
done

for f in *.rar
do
  [[ "$f" =~ part([0-9]+).rar ]] && continue;
  e_header "Processing file $f"
  $CMD "$f" >> "$LOG"
  post_uncompress $? "$f"
done

terminate_uncompress
