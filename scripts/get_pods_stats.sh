#!/bin/bash

# Usage
# ./get_pods_stats.sh <DIR> <WORKER_NODE>

USER="root"
WORKER_PATH="/root"

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
fi

DIR=$1

NODE=$2

echo "Copying BF stats from ${NODE} to ${DIR}"
scp ${USER}@${NODE}:${WORKER_PATH}/epi-* ${DIR}
