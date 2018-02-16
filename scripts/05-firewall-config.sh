#!/bin/bash
# If using OpenStack, security groups must also be added

# Get the variables
source 00-variables.sh

#https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0/supported_system_config/required_ports.html
MASTER_PORTS=("8101" "179" "9099" "8500" "8743" "5044" "5046" "9100" "9200" "9300" "2380" "3306" "4567" "3130" "4568" "4444" "4001" "8082" "8084" "4500" "4300" "8600" "80" "443" "8181" "18080" "5000" "35357" "4194" "10248:10252" "30000:32767" "8001" "8888" "8080" "8443" "9235" "9443" "24007" "24008" "2222" "49152:49251" "31030" "31031" "6969" "4242")
WORKER_PORTS=("179" "9099" "4300" "4194" "10248:10252" "30000:32767" "8001" "8888" "24007" "24008" "2222" "49152:49251" "9100" "4500")
PROXY_PORTS=("179" "9099" "80" "443" "8181" "18080" "4194" "10248:10252" "30000:32767" "9100" "4500")
MANAGEMENT_PORTS=("179" "9099" "8743" "5044" "5046" "9200" "9300" "3130" "9100")

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

echo "Setting up port access via iptables on proxies  ..."
#  Is this really the same as workers?
for ((i=0; i < $NUM_PROXIES; i++)); do
  # Disable SELinux
  if [ "${OS}" == "rhel" ]; then
    ssh ${SSH_USER}@${PROXY_HOSTNAMES[i]} sudo systemctl stop firewalld.service
  else
    ssh ${SSH_USER}@${PROXY_HOSTNAMES[i]} sudo ufw disable
    ssh ${SSH_USER}@${PROXY_HOSTNAMES[i]} sudo ufw allow ssh
  fi
  for port in "${PROXY_PORTS[@]}"; do
    ssh ${SSH_USER}@${PROXY_HOSTNAMES[i]} sudo iptables -A INPUT -p tcp -m tcp --sport $port -j ACCEPT
    ssh ${SSH_USER}@${PROXY_HOSTNAMES[i]} sudo iptables -A OUTPUT -p tcp -m tcp --dport $port -j ACCEPT
  done

  # Do we need this?
  if [ "${OS}" == "rhel" ]; then
    ssh ${SSH_USER}@${PROXY_HOSTNAMES[i]} sudo service iptables restart
  else
    ssh ${SSH_USER}@${PROXY_HOSTNAMES[i]} sudo ufw allow ssh
    #ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo ufw --force enable
    #ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo ufw status
  fi
done

echo "Setting up port access via iptables on management node(s) ..."
for ((i=0; i < $NUM_MANAGERS; i++)); do
  # Disable SELinux
  if [ "${OS}" == "rhel" ]; then
    ssh ${SSH_USER}@${MANAGEMENT_HOSTNAMES[i]} sudo systemctl stop firewalld.service
  else
    ssh ${SSH_USER}@${MANAGEMENT_HOSTNAMES[i]} sudo ufw disable
    ssh ${SSH_USER}@${MANAGEMENT_HOSTNAMES[i]} sudo ufw allow ssh
  fi
  for port in "${MANAGEMENT_PORTS[@]}"; do
    ssh ${SSH_USER}@${MANAGEMENT_HOSTNAMES[i]} sudo iptables -A INPUT -p tcp -m tcp --sport $port -j ACCEPT
    ssh ${SSH_USER}@${MANAGEMENT_HOSTNAMES[i]} sudo iptables -A OUTPUT -p tcp -m tcp --dport $port -j ACCEPT
  done

  # Do we need this?
  if [ "${OS}" == "rhel" ]; then
    ssh ${SSH_USER}@${MANAGEMENT_HOSTNAMES[i]} sudo service iptables restart
  else
    ssh ${SSH_USER}@${MANAGEMENT_HOSTNAMES[i]} sudo ufw allow ssh
    #ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo ufw --force enable
    #ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo ufw status
  fi
done
