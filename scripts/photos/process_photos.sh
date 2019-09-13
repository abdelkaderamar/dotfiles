# in processing1  
exiftool  '-FileName<../Photos - Classified/${model}/${CreateDate}' -d '%Y-%m-%d/%Y-%m-%d_%H%M%S.%%e'  -P -r .

# in processing2 (the ./ in filename is used to move the files to the current directory)
exiftool  '-FileName<./${CreateDate}' -d '%Y-%m-%d_%H%M%S.%%e'  -P -r .

