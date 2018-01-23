#!/bin/bash
# If using OpenStack, security groups must also be added

# Get the variables
source 00-variables.sh

#https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0/supported_system_config/required_ports.html
MASTER_PORTS=("8101" "179" "8500" "8743" "5044" "5046" "9200" "9300" "2380" "4001" "8082" "8084" "4500" "4300" "8600" "80" "443" "8181" "18080" "5000" "35357" "4194" "10248:10252" "30000:32767" "8001" "8888" "8080" "8443" "9235" "9443")
WORKER_PORTS=("179" "4300" "4194" "10248:10252" "30000:32767" "8001" "8888")
# Stop firewall
if [ "${OS}" == "rhel" ]; then
  sudo systemctl stop firewalld.service
else
  sudo ufw disable
fi

echo "Be Aware -- this script runs a bit longer than the rest.  Be patient"
echo "Setting up port access via iptables on master ..."
# Open required ports
for port in "${MASTER_PORTS[@]}"; do
  sudo iptables -A INPUT -p tcp -m tcp --sport $port -j ACCEPT
  sudo iptables -A OUTPUT -p tcp -m tcp --dport $port -j ACCEPT
done

echo "Enabling SSH access to facilitate installation"
sudo ufw allow ssh

# Do we need this?
if [ "${OS}" == "rhel" ]; then
  sudo service iptables restart
else
  echo "Firewall for Ubuntu will remain off for installation ..."
  #sudo ufw --force enable
  #sudo ufw status; #verbose;
  #sudo iptables -L;
fi

echo "Setting up port access via iptables on workers ..."
for ((i=0; i < $NUM_WORKERS; i++)); do
  # Disable SELinux
  if [ "${OS}" == "rhel" ]; then
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo systemctl stop firewalld.service
  else
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo ufw disable
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo ufw allow ssh
  fi
  for port in "${WORKER_PORTS[@]}"; do
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo iptables -A INPUT -p tcp -m tcp --sport $port -j ACCEPT
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo iptables -A OUTPUT -p tcp -m tcp --dport $port -j ACCEPT
  done

  # Do we need this?
  if [ "${OS}" == "rhel" ]; then
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo service iptables restart
  else
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo ufw allow ssh
    #ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo ufw --force enable
    #ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo ufw status
  fi
done

