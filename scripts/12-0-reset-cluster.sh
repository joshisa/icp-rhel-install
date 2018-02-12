#!/bin/bash
# ----------------------------------------------------------------------------------------------------\\
# Description:
#   A basic reset of the cluster and its workers for RHEL 7.4 or Ubuntu 16.04
# ----------------------------------------------------------------------------------------------------\\
# Get the variables
source 00-variables.sh

sudo systemctl restart kubelet docker
echo "Looping through workers ..."
for ((i=0; i < $NUM_WORKERS; i++)); do
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo systemctl restart kubelet docker
done

