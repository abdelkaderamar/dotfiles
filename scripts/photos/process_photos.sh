# in processing1  
exiftool  '-FileName<../Classified/${model}/${CreateDate}' -d '%Y-%m-%d/%Y-%m-%d_%H%M%S.%%e'  -P -r -progress .

# in processing2 (the ./ in filename is used to move the files to the current directory)
exiftool  '-FileName<./${CreateDate}' -d '%Y-%m-%d_%H%M%S.%%e'  -P -r -progress .

