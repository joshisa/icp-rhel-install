#!/bin/bash

# Get the variables
source 00-variables.sh

# Make a new key so we are not reusing our key for server communications
ssh-keygen -b 4096 -t rsa -f ~/.ssh/master.id_rsa -N ""
sudo mkdir -p /root/.ssh
cat ~/.ssh/master.id_rsa.pub | sudo tee /root/.ssh/authorized_keys | tee -a ~/.ssh/authorized_keys


# Make sure SSH uses this key by default (makes next commands easier)
# no quotes in echo so ~ expands to usr root
echo IdentityFile ~/.ssh/master.id_rsa | sudo tee -a /root/.ssh/config | tee -a ~/.ssh/config

# Loop through the array
for ((i=0; i < $NUM_WORKERS; i++)); do
  # Prevent SSH identity prompts
  # If hostname exists in known hosts remove it
  ssh-keygen -R ${WORKER_HOSTNAMES[i]}
  # Add hostname to known hosts
  ssh-keyscan -H ${WORKER_HOSTNAMES[i]} | tee -a ~/.ssh/known_hosts
  
  # Allow root and user login
  ssh -i ${SSH_KEY} ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo mkdir -p /root/.ssh
  scp -i ${SSH_KEY} ~/.ssh/master.id_rsa.pub ${SSH_USER}@${WORKER_HOSTNAMES[i]}:~/.ssh/master.id_rsa.pub

  ssh -i ${SSH_KEY} ${SSH_USER}@${WORKER_HOSTNAMES[i]} 'cat ~/.ssh/master.id_rsa.pub | sudo tee /root/.ssh/authorized_keys | tee -a ~/.ssh/authorized_keys; echo "PermitRootLogin yes" | sudo tee -a /etc/ssh/sshd_config'
  ssh -i ${SSH_KEY} ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo service sshd restart
done

# Loop through the array
for ((i=0; i < $NUM_PROXIES; i++)); do
  # Prevent SSH identity prompts
  # If hostname exists in known hosts remove it
  ssh-keygen -R ${PROXY_HOSTNAMES[i]}
  # Add hostname to known hosts
  ssh-keyscan -H ${PROXY_HOSTNAMES[i]} | tee -a ~/.ssh/known_hosts

  # Allow root and user login
  ssh -i ${SSH_KEY} ${SSH_USER}@${PROXY_HOSTNAMES[i]} sudo mkdir -p /root/.ssh
  scp -i ${SSH_KEY} ~/.ssh/master.id_rsa.pub ${SSH_USER}@${PROXY_HOSTNAMES[i]}:~/.ssh/master.id_rsa.pub

  ssh -i ${SSH_KEY} ${SSH_USER}@${PROXY_HOSTNAMES[i]} 'cat ~/.ssh/master.id_rsa.pub | sudo tee /root/.ssh/authorized_keys | tee -a ~/.ssh/authorized_keys; echo "PermitRootLogin yes" | sudo tee -a /etc/ssh/sshd_config'
  ssh -i ${SSH_KEY} ${SSH_USER}@${PROXY_HOSTNAMES[i]} sudo service sshd restart
done

# Loop through the array
for ((i=0; i < $NUM_MANAGERS; i++)); do
  # Prevent SSH identity prompts
  # If hostname exists in known hosts remove it
  ssh-keygen -R ${MANAGEMENT_HOSTNAMES[i]}
  # Add hostname to known hosts
  ssh-keyscan -H ${MANAGEMENT_HOSTNAMES[i]} | tee -a ~/.ssh/known_hosts

  # Allow root and user login
  ssh -i ${SSH_KEY} ${SSH_USER}@${MANAGEMENT_HOSTNAMES[i]} sudo mkdir -p /root/.ssh
  scp -i ${SSH_KEY} ~/.ssh/master.id_rsa.pub ${SSH_USER}@${MANAGEMENT_HOSTNAMES[i]}:~/.ssh/master.id_rsa.pub

  ssh -i ${SSH_KEY} ${SSH_USER}@${MANAGEMENT_HOSTNAMES[i]} 'cat ~/.ssh/master.id_rsa.pub | sudo tee /root/.ssh/authorized_keys | tee -a ~/.ssh/authorized_keys; echo "PermitRootLogin yes" | sudo tee -a /etc/ssh/sshd_config'
  ssh -i ${SSH_KEY} ${SSH_USER}@${MANAGEMENT_HOSTNAMES[i]} sudo service sshd restart
done

# Loop through the array
for ((i=0; i < $NUM_VA; i++)); do
  # Prevent SSH identity prompts
  # If hostname exists in known hosts remove it
  ssh-keygen -R ${VA_HOSTNAMES[i]}
  # Add hostname to known hosts
  ssh-keyscan -H ${VA_HOSTNAMES[i]} | tee -a ~/.ssh/known_hosts

  # Allow root and user login
  ssh -i ${SSH_KEY} ${SSH_USER}@${VA_HOSTNAMES[i]} sudo mkdir -p /root/.ssh
  scp -i ${SSH_KEY} ~/.ssh/master.id_rsa.pub ${SSH_USER}@${VA_HOSTNAMES[i]}:~/.ssh/master.id_rsa.pub

  ssh -i ${SSH_KEY} ${SSH_USER}@${VA_HOSTNAMES[i]} 'cat ~/.ssh/master.id_rsa.pub | sudo tee /root/.ssh/authorized_keys | tee -a ~/.ssh/authorized_keys; echo "PermitRootLogin yes" | sudo tee -a /etc/ssh/sshd_config'
  ssh -i ${SSH_KEY} ${SSH_USER}@${VA_HOSTNAMES[i]} sudo service sshd restart
done
