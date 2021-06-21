#!/usr/bin/env bash

mkdir /data
HOSTNAME=$(hostname)
FILE=${1:-/data/$HOSTNAME.txt}

echo '"Time","CPU","Memory"' > $FILE

while true; do
    sleep 1;
    read -rst5 MEMORY </sys/fs/cgroup/memory/memory.usage_in_bytes
    read -rst5 CPU    </sys/fs/cgroup/cpu/cpuacct.usage
    read -rst5 DATE   < <(date +"%FT%T.%3N")
    echo "$DATE,$CPU,$MEMORY";
done >> $FILE;