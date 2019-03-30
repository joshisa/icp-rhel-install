#!/bin/bash

# Get the variables
source 00-variables.sh

# Disable SELinux
if [ "${OS}" == "rhel" ]; then
  sudo setenforce 0
fi

# Set VM max map count (see max_map_count https://www.kernel.org/doc/Documentation/sysctl/vm.txt)
sudo sysctl -w vm.max_map_count=262144
echo vm.max_map_count=262144 | sudo tee -a /etc/sysctl.conf

# Sync time
sudo ntpdate -s time.nist.gov

# Start docker
sudo service docker start


for ((i=0; i < $NUM_WORKERS; i++)); do
  # Disable SELinux
  if [ "${OS}" == "rhel" ]; then
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo setenforce 0
  fi

  # Set VM max map count
  ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo sysctl -w vm.max_map_count=262144
  ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} "echo vm.max_map_count=262144 | sudo tee -a /etc/sysctl.conf"

  # Sync time
  ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo ntpdate -s time.nist.gov

  # Start docker
  ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo service docker start

done

echo "Looping through gluster workers to prepare them ..."
for ((i=0; i < $NUM_GLWORKERS; i++)); do
  # Install docker & python on worker
  if [ "${OS}" == "rhel" ]; then
    echo "Installing for RHEL ...."
    ssh ${SSH_USER}@${GLWORKER_HOSTNAMES[i]} "sudo modprobe dm_thin_pool"
    ssh ${SSH_USER}@${GLWORKER_HOSTNAMES[i]} "echo dm_thin_pool | sudo tee -a /etc/modules-load.d/dm_thin_pool.conf"
  else # ubuntu
    echo "Installing for Ubuntu ...."
    ssh ${SSH_USER}@${GLWORKER_HOSTNAMES[i]} "sudo modprobe dm_thin_pool"
    ssh ${SSH_USER}@${GLWORKER_HOSTNAMES[i]} "echo dm_thin_pool | sudo tee -a /etc/modules"
  fi
done

for ((i=0; i < $NUM_PROXIES; i++)); do
  # Disable SELinux
  if [ "${OS}" == "rhel" ]; then
    ssh ${SSH_USER}@${PROXY_HOSTNAMES[i]} sudo setenforce 0
  fi

  # Set VM max map count
  ssh ${SSH_USER}@${PROXY_HOSTNAMES[i]} sudo sysctl -w vm.max_map_count=262144
  ssh ${SSH_USER}@${PROXY_HOSTNAMES[i]} "echo vm.max_map_count=262144 | sudo tee -a /etc/sysctl.conf"

  # Sync time
  ssh ${SSH_USER}@${PROXY_HOSTNAMES[i]} sudo ntpdate -s time.nist.gov

  # Start docker
  ssh ${SSH_USER}@${PROXY_HOSTNAMES[i]} sudo service docker start

done

for ((i=0; i < $NUM_MANAGERS; i++)); do
  # Disable SELinux
  if [ "${OS}" == "rhel" ]; then
    ssh ${SSH_USER}@${MANAGEMENT_HOSTNAMES[i]} sudo setenforce 0
  fi

  # Set VM max map count
  ssh ${SSH_USER}@${MANAGEMENT_HOSTNAMES[i]} sudo sysctl -w vm.max_map_count=262144
  ssh ${SSH_USER}@${MANAGEMENT_HOSTNAMES[i]} "echo vm.max_map_count=262144 | sudo tee -a /etc/sysctl.conf"

  # Sync time
  ssh ${SSH_USER}@${MANAGEMENT_HOSTNAMES[i]} sudo ntpdate -s time.nist.gov

  # Start docker
  ssh ${SSH_USER}@${MANAGEMENT_HOSTNAMES[i]} sudo service docker start

done

for ((i=0; i < $NUM_VA; i++)); do
  # Disable SELinux
  if [ "${OS}" == "rhel" ]; then
    ssh ${SSH_USER}@${VA_HOSTNAMES[i]} sudo setenforce 0
  fi

  # Set VM max map count
  ssh ${SSH_USER}@${VA_HOSTNAMES[i]} sudo sysctl -w vm.max_map_count=262144
  ssh ${SSH_USER}@${VA_HOSTNAMES[i]} "echo vm.max_map_count=262144 | sudo tee -a /etc/sysctl.conf"

  # Sync time
  ssh ${SSH_USER}@${VA_HOSTNAMES[i]} sudo ntpdate -s time.nist.gov

  # Start docker
  ssh ${SSH_USER}@${VA_HOSTNAMES[i]} sudo service docker start

done
