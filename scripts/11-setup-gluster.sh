#!/usr/bin/env bash

set -e
set -u

export NUM_PVS_START_NUM=0
export NUM_PVS_RWO_RECYCLE=5
export NUM_PVS_RWX_RECYCLE=5
export mode="create" #"delete"

export GLUSTER_CLUSTER_IPS=("10.10.25.13" "10.10.25.14" "10.10.25.15")
export GLUSTER_CLUSTER_NAME="glusterfs-cluster"
export GLUSTER_CLUSTER_VOL="gvol0"
export NUM_GLUSTER_BRICKS=${#GLUSTER_CLUSTER_IPS[@]}

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
      storage: 5Gi
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
      storage: 5Gi
    glusterfs:
      endpoints: ${GLUSTER_CLUSTER_NAME}
      path: ${GLUSTER_CLUSTER_VOL}
    persistentVolumeReclaimPolicy: Recycle
EOF
done
