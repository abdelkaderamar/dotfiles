#! /bin/bash -u

usage()
{
    echo Usage
    echo '  ' `basename $0` '<time> <cmd> [{args}]'
}

[[ $# -lt 2 ]] && usage && exit 1

until_time=$1
until_time_in_sec=`date --date="$until_time" +%s`
echo $until_time
shift

cmd=$1
echo $cmd
shift

while (true)
do
    $cmd $@
    result=$?
    
    sleep 30

    current_time=`date +%Y-%m-%d\ %H:%M:%S`
    current_time_in_sec=`date --date="$current_time" +%s`
    let "time_diff=$until_time_in_sec-$current_time_in_sec"
    if [ $time_diff -lt 0 ]
    then
	echo exiting at $(date)
	exit $result
    fi    
done
