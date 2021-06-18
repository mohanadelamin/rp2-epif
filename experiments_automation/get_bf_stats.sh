#!/bin/bash

# Usage
# ./get_bf_stats.sh <DIR> <WORKER_NODE_1> <WORKER_NODE_2> ... 

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
fi

DIR=$1

shift
while test ${#} -gt 0
do
    echo "Copying BF stats from $1 to $DIR"
    scp root@$1:/root/epi-bf-* $DIR
    shift
done
