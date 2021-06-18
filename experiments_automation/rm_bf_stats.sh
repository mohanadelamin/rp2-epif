#!/bin/bash

# Usage
# ./rm_bf_stats.sh <WORKER_NODE_1> <WORKER_NODE_2> ... 

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
fi

DIR=$1

while test ${#} -gt 0
do
    echo "Removing BF stats from $1"
    ssh root@$1 'rm /root/epi-bf-*'
    shift
done
