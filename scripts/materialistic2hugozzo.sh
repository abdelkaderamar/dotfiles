#! /bin/bash -u

function usage()
{
  e_header "Usage $(basename $0) <materialistic url file>"
  echo
  e_arrow "$@"
  echo
  e_header "This script is used to import materialistic exported links of hackernews to hugo blog"
  e_header "Materialistic is an open source android app to read Hackernews"
  e_arrow  "     https://play.google.com/store/apps/details?id=io.github.hidroh.materialistic"
  e_arrow  "     https://github.com/hidroh/materialistic"
}

function sanitize() 
{ 
  STRING=$1 
  CLEAN=${STRING//_/} 
  CLEAN=${CLEAN// /_} 
  CLEAN=${CLEAN//[^a-zA-Z0-9_]/} 
  CLEAN=`echo -n $CLEAN | tr A-Z a-z`; 
}

function create_post()
{
    title="$1"
    itemurl="$2"
    commenturl="$3"
    timestamp="$4"

    
    #publish_time=$(date +'%Y-%m-%dT%H:%M:%S%z')
    
    publish_date=$(date -d "@$timestamp" +'%Y-%m-%dT%H:%M:%S%z')
    file_date=$(date -d "@$timestamp" +'%Y%m%d')

    dir=$(date -d "@$timestamp" +'%Y-%m')
    post_dir="$HUGO_HOME"/content/hn/"${dir}"

    mkdir -p "$post_dir"
    
    sanitize "$title"
    post_filename="${post_dir}/${file_date}-${CLEAN}.md"
    echo "---" > "$post_filename"
    echo "title: \"$title\"" >> "$post_filename"
    echo "itemurl: \"$itemurl\"" >> "$post_filename"
    echo "commenturl: \"$commenturl\"" >> "$post_filename"
    echo "date: $publish_date" >> "$post_filename"
    echo "---" >> "$post_filename"

}

. $HOME/.bash_logging

if [ -z ${HUGO_HOME+x} ]; then usage "Please set HUGO_HOME variable" ; exit 1; fi

if [ $# -lt 1 ]; then usage "Provide a materialistic file"; exit 1; fi

file="$1"

titles=[]
hn_urls=[]
article_urls=[]
len=0
while read title
do
    read article_url
    read hn_url
    read empty_line
    titles[$len]="$title"
    hn_urls[$len]="$hn_url"
    article_urls[$len]="$article_url"
    len=$((len+1))
done < "$file"

for((i=0;i<len;++i))
do
    title=${titles[$i]}
    itemurl=${article_urls[$i]}
    commenturl=${hn_urls[$i]}

    id=$(echo "$commenturl"  | sed 's/^.*item?id=\(.*\)/\1/')
    timestamp=$(curl -s "https://hacker-news.firebaseio.com/v0/item/${id}.json?print=pretty" | jq -r '.time')
    
    echo Title  = $title
    echo URL    = $itemurl
    echo HN URL = $commenturl
    echo timestamp   = $timestamp
    #echo -n "Proceed (y/n) "
    #read l
    l=y
    if [ "$l" == "y" ]
    then
	create_post "$title" "$itemurl" "$commenturl" "$timestamp"
    fi
    echo
done
