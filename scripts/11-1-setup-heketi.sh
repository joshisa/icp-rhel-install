#!/usr/bin/env bash

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

# Create Endpoint Based on Gluster Cluster IPs
endpoint_yaml=$(
  echo "apiVersion: v1"
  echo "kind: Endpoints"
  echo "metadata:"
  echo "  name: ${GLUSTER_CLUSTER_NAME}"
  echo "  namespace: default"
  echo "subsets:"
  echo "- addresses:"
  for ((i=0; i < $NUM_GLUSTER_BRICKS; i++)); do
    echo "  - ip: ${GLUSTER_CLUSTER_IPS[i]}"
  done
  echo "  ports:"
  echo "  - port: 1729"
)

echo "${endpoint_yaml}" > ./endpoint.yml
kubectl ${mode} -f ./endpoint.yml
rm ./endpoint.yml


# Create Service Based on Gluster Cluster IPs
cat <<EOF | kubectl ${mode} -f -
  kind: Service
  apiVersion: v1
  metadata:
    name: ${GLUSTER_CLUSTER_NAME}
  spec:
    ports:
    - port: 1729
EOF


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
