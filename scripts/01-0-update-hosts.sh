#!/bin/bash
# Constructs hosts file

# Get the variables
source 00-variables.sh

# Back up old hosts file
sudo cp /etc/hosts /etc/hosts.bak

echo "127.0.0.1 localhost" | sudo tee /etc/hosts
echo "" | sudo tee -a /etc/hosts

echo "fe00::0 ip6-localnet" | sudo tee -a /etc/hosts
echo "ff00::0 ip6-mcastprefix" | sudo tee -a /etc/hosts
echo "ff02::1 ip6-allnodes" | sudo tee -a /etc/hosts
echo "ff02::2 ip6-allrouters" | sudo tee -a /etc/hosts
echo "ff02::3 ip6-allhosts" | sudo tee -a /etc/hosts
echo "" | sudo tee -a /etc/hosts

# Loop through the array
for ((i=0; i < $NUM_WORKERS; i++)); do
  echo "${WORKER_IPS[i]} ${WORKER_HOSTNAMES[i]}" | sudo tee -a /etc/hosts
done
echo "" | sudo tee -a /etc/hosts

sudo cp /etc/hosts ~/worker-hosts
sudo chown $USER ~/worker-hosts

echo "$MASTER_IP mycluster.icp" | sudo tee -a /etc/hosts

for ((i=0; i < $NUM_WORKERS; i++)); do
  # Remove old instance of host
  ssh-keygen -R ${WORKER_IPS[i]}
  ssh-keygen -R ${WORKER_HOSTNAMES[i]}

  # Do not ask to verify fingerprint of server on ssh
  ssh-keyscan -H ${WORKER_IPS[i]} >> ~/.ssh/known_hosts
  ssh-keyscan -H ${WORKER_HOSTNAMES[i]} >> ~/.ssh/known_hosts

  # Copy over file
  sudo scp -i ${SSH_KEY} ~/worker-hosts  ${SSH_USER}@${WORKER_HOSTNAMES[i]}:~/worker-hosts

  # Replace worker hosts with file
  ssh -i ${SSH_KEY} ${SSH_USER}@${WORKER_HOSTNAMES[i]} 'sudo cp /etc/hosts /etc/hosts.bak; sudo mv ~/worker-hosts /etc/hosts'
done
