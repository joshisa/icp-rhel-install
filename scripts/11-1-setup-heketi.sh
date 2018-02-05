#!/usr/bin/env bash

# PLACEHOLDER ... No work started yet on this.
set -e
set -u

# Get the variables
source 00-variables.sh

export NUM_PVS_START_NUM=0
export NUM_PVS_RWO_RECYCLE=5
export NUM_PVS_RWX_RECYCLE=5
export STORAGE_SIZE="5Gi"
export mode="create" #"delete"

export GLUSTER_CLUSTER_IPS=("x.x.x.x" "x.x.x.x" "x.x.x.x")
export GLUSTER_CLUSTER_NAME="glusterfs-cluster"
export GLUSTER_CLUSTER_VOL="gvol0"
export NUM_GLUSTER_BRICKS=${#GLUSTER_CLUSTER_IPS[@]}

if [ "${OS}" == "rhel" ]; then
    yum install -y glusterfs-client
else
  sudo apt-get install -y glusterfs-client
fi

for ((i=0; i < $NUM_WORKERS; i++)); do
  if [ "${OS}" == "rhel" ]; then
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} yum install -y glusterfs-client
  else
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo apt-get install -y glusterfs-client
  fi
done
