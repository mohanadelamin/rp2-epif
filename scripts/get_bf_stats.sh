#!/bin/bash

# Usage
# ./get_bf_stats.sh <DIR> <WORKER_NODE>

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
fi

DIR=$1

NODE=$2

echo "Copying BF stats from ${NODE} to ${DIR}"
scp root@${NODE}:/root/epi-bf-* ${DIR}
