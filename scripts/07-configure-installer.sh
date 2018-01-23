#!/bin/bash

# Get the variables
source 00-variables.sh

# Move SSH key
sudo cp ~/.ssh/master.id_rsa /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/ssh_key

# Configure hosts
echo "[master]" | sudo tee /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/hosts
echo "${MASTER_IP}" | sudo tee -a /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/hosts
echo "" | sudo tee -a /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/hosts

echo "[worker]" | sudo tee -a /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/hosts
for ((i=0; i < $NUM_WORKERS; i++)); do
  echo ${WORKER_IPS[i]} | sudo tee -a /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/hosts
done
echo "" | sudo tee -a /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/hosts

echo "[proxy]" | sudo tee -a /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/hosts
echo "${MASTER_IP}" | sudo tee -a /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/hosts

# Add line for external IP in config
echo "cluster_access_ip: ${PUBLIC_IP}" | sudo tee -a /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/config.yaml
echo "proxy_access_ip: ${PUBLIC_IP}" | sudo tee -a /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/config.yaml
