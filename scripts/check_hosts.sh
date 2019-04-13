#! /bin/bash -u

usage()
{
    echo Usage
    echo "   "`basename $0` {hosts}
}

if [ $# -lt 1 ]
then
    usage
    exit 1
fi

while true
do
    sleep 1800

    for i in "$@"
    do
	host=$i
	ssh "$host" "ls > /dev/null"
	res=$?

	if [ $res -ne 0 ]
	then
	    sms.sh "The host $host is unreachable"
	fi
    done
    
done
