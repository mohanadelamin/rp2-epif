#!/bin/bash
# Usage
# ./rm_pods_stats.sh <WORKER_NODE>

USER="root"
WORKER_PATH="/root"

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
fi

NODE=$1

echo "Removing BF stats from ${NODE}"
ssh ${USER}@${NODE} 'rm ${WORKER_PATH}/epi-*'
