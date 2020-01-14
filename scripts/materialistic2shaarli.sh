#! /bin/bash -u

file="$1"

titles=[]
urls=[]
len=0
while read title
do
    read article_url
    read hn_url
    read empty_line
    titles[$len]="$title"
    urls[$len]="$hn_url"
    len=$((len+1))
done < "$file"

for((i=0;i<len;++i))
do
    echo Title = ${titles[$i]}
    echo URL   = ${urls[$i]}
    echo -n "Proceed (y/n) "
    #read l
    l=y
    if [ "$l" == "y" ]
    then
	shaarli post-link --url "${urls[$i]}" --tags "HN" --title "${titles[$i]}"
	sleep 1
    fi
    if [ $? -ne 0 ]
    then
	echo "Failed to add ${titles[$i]} | ${urls[$i]}"
	exit 1
    fi
    echo
done
