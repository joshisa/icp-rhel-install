#!/usr/bin/env bash

set -e
set -u

# Get the variables
source 00-variables.sh

export NUM_PVS_START_NUM=1
export NUM_PVS_RWO_RECYCLE=2
export NUM_PVS_RWX_RECYCLE=0
export STORAGE_SIZE="2Gi"
export mode="create" #"delete"

export GLUSTER_CLUSTER_IPS=("x.x.x.x" "x.x.x.x" "x.x.x.x")
export GLUSTER_CLUSTER_NAME="glusterfs-cluster"
export GLUSTER_CLUSTER_VOL="gvol0"
export NUM_GLUSTER_BRICKS=${#GLUSTER_CLUSTER_IPS[@]}

# Create a set of persisted volumes with attribute of RWO
for ((i=$NUM_PVS_START_NUM; i < $NUM_PVS_RWO_RECYCLE; i++)); do
  echo "${mode} gluster-pv-${i}"
  cat <<EOF | kubectl ${mode} -f -
  apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: gluster-pv-once-${i}
  spec:
    accessModes:
    - ReadWriteOnce
    capacity:
      storage: ${STORAGE_SIZE}
    glusterfs:
      endpoints: ${GLUSTER_CLUSTER_NAME}
      path: ${GLUSTER_CLUSTER_VOL}
    persistentVolumeReclaimPolicy: Recycle
EOF
done

# Create a set of persisted volumes with attribute of RWX
for ((i=$NUM_PVS_START_NUM; i < $NUM_PVS_RWX_RECYCLE; i++)); do
  echo "${mode} gluster-pv-${i}"
  cat <<EOF | kubectl ${mode} -f -
  apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: gluster-pv-many-${i}
  spec:
    accessModes:
    - ReadWriteMany
    capacity:
      storage: ${STORAGE_SIZE}
    glusterfs:
      endpoints: ${GLUSTER_CLUSTER_NAME}
      path: ${GLUSTER_CLUSTER_VOL}
    persistentVolumeReclaimPolicy: Recycle
EOF
done
