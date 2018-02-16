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
if [ ${NUM_PROXIES} -gt "0" ]; then
  for ((i=0; i < $NUM_PROXIES; i++)); do
    echo "${PROXY_IPS[i]}" | sudo tee -a /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/hosts
  done
else
  echo "No Proxy IPs provided.  Defaulting to co-location of Proxy Node on Master"
  echo "${MASTER_IP}" | sudo tee -a /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/hosts 
fi
echo "" | sudo tee -a /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/hosts

echo "[management]" | sudo tee -a /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/hosts
if [ ${NUM_MANAGERS} -gt "0" ]; then
  for ((i=0; i < $NUM_MANAGERS; i++)); do
    echo "${MANAGEMENT_IPS[i]}" | sudo tee -a /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/hosts
  done
  echo "" | sudo tee -a /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/hosts
else
  echo "No Management Node IPs provided."
fi

# Add line for external IP in config
echo "cluster_access_ip: ${PUBLIC_IP}" | sudo tee -a /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/config.yaml
echo "proxy_access_ip: ${PUBLIC_IP}" | sudo tee -a /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/config.yaml
echo "kibana_install: true" | sudo tee -a /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/config.yaml
echo "ingress_enabled: true" | sudo tee -a /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/config.yaml

# Enabling Vulnerability Advisor
echo 'disabled_management_services: [""]' | sudo tee -a /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/config.yaml
#echo "federation_enabled: true" | sudo tee -a /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/config.yaml
#echo "federation_cluster: federation-cluster" | sudo tee -a /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/config.yaml
#echo "federation_domain: cluster.federation" | sudo tee -a /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/config.yaml
