#!/bin/bash
# User steps for password-less communications

source ./00-variables.sh

# Start SSH Agent
if [ "${OS}" == "rhel" ]; then
   echo "RHEL Detected ..."
else
  eval "$(ssh-agent -s)"
  ssh-add "${SSH_KEY}"
  ssh-add -l
fi

# Generate RSA key
ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -N ""

# Move RSA key to workers
for ((i=0; i < $NUM_WORKERS; i++)); do
  # Prevent SSH identity prompts
  # If host IP exists in known hosts remove it
  ssh-keygen -R ${WORKER_IPS[i]}
  # Add host IP to known hosts
  ssh-keyscan -H ${WORKER_IPS[i]} | tee -a ~/.ssh/known_hosts
  
  # Copy over key (Will prompt for password)
  scp ~/.ssh/id_rsa.pub ${SSH_USER}@${WORKER_IPS[i]}:~/id_rsa.pub
  ssh ${SSH_USER}@${WORKER_IPS[i]} 'mkdir -p ~/.ssh; cat ~/id_rsa.pub | tee -a ~/.ssh/authorized_keys'
done

# Move RSA key to proxies
for ((i=0; i < $NUM_PROXIES; i++)); do
  # Prevent SSH identity prompts
  # If host IP exists in known hosts remove it
  ssh-keygen -R ${PROXY_IPS[i]}
  # Add host IP to known hosts
  ssh-keyscan -H ${PROXY_IPS[i]} | tee -a ~/.ssh/known_hosts

  # Copy over key (Will prompt for password)
  scp ~/.ssh/id_rsa.pub ${SSH_USER}@${PROXY_IPS[i]}:~/id_rsa.pub
  ssh ${SSH_USER}@${PROXY_IPS[i]} 'mkdir -p ~/.ssh; cat ~/id_rsa.pub | tee -a ~/.ssh/authorized_keys'
done

# Move RSA key to management node
for ((i=0; i < $NUM_MANAGERS; i++)); do
  # Prevent SSH identity prompts
  # If host IP exists in known hosts remove it
  ssh-keygen -R ${MANAGEMENT_IPS[i]}
  # Add host IP to known hosts
  ssh-keyscan -H ${MANAGEMENT_IPS[i]} | tee -a ~/.ssh/known_hosts

  # Copy over key (Will prompt for password)
  scp ~/.ssh/id_rsa.pub ${SSH_USER}@${MANAGEMENT_IPS[i]}:~/id_rsa.pub
  ssh ${SSH_USER}@${MANAGEMENT_IPS[i]} 'mkdir -p ~/.ssh; cat ~/id_rsa.pub | tee -a ~/.ssh/authorized_keys'
done

echo IdentityFile ~/.ssh/id_rsa | tee -a ~/.ssh/config
