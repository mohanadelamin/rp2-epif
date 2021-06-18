#!/bin/bash
# Usage
# ./rm_bf_stats.sh <WORKER_NODE>

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
fi

NODE=$1

echo "Removing BF stats from ${NODE}"
ssh root@${NODE} 'rm /root/epi-bf-*'
