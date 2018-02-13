#!/bin/bash
# ----------------------------------------------------------------------------------------------------\\
# Description:
#   A basic reset of the cluster and its workers for RHEL 7.4 or Ubuntu 16.04
# ----------------------------------------------------------------------------------------------------\\
# Get the variables
source 00-variables.sh

echo "Looping through workers ..."
for ((i=0; i < $NUM_WORKERS; i++)); do
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo apt-get remove -y docker-ce
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo apt-get purge -y docker-ce
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo apt-get autoremove -y --purge docker-ce
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo apt-get autoclean
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo rm -rf /var/lib/docker
done

echo "Looping through management ..."
for ((i=0; i < $NUM_MANAGERS; i++)); do
    ssh ${SSH_USER}@${MANAGEMENT_HOSTNAMES[i]} sudo apt-get remove -y docker-ce
    ssh ${SSH_USER}@${MANAGEMENT_HOSTNAMES[i]} sudo apt-get purge -y docker-ce
    ssh ${SSH_USER}@${MANAGEMENT_HOSTNAMES[i]} sudo apt-get autoremove -y --purge docker-ce
    ssh ${SSH_USER}@${MANAGEMENT_HOSTNAMES[i]} sudo apt-get autoclean
    ssh ${SSH_USER}@${MANAGEMENT_HOSTNAMES[i]} sudo rm -rf /var/lib/docker
done
