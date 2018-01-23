#!/bin/bash

# Get the variables
source 00-variables.sh

# Must have yum configured on all hosts prior to running this step

#TODO: Make theses steps run in parallel

# Install docker & python on master
if [ "$ARCH" == "ppc64le" ]; then
  # https://developer.ibm.com/linuxonpower/docker-on-power/
  echo -e "[docker]\nname=Docker\nbaseurl=http://ftp.unicamp.br/pub/ppc64el/rhel/7/docker-ppc64el/\nenabled=1\ngpgcheck=0\n" | sudo tee /etc/yum.repos.d/docker.repo
else
  if [ "${OS}" == "rhel" ]; then
    sudo yum install -y yum-utils device-mapper-persistent-data lvm2
    sudo yum-config-manager -y --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  fi
fi

if [ "${OS}" == "rhel" ]; then
  sudo yum install -y yum-utils device-mapper-persistent-data lvm2
  sudo yum-config-manager -y --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  sudo yum install -y docker-ce

  sudo yum install -y python-setuptools
  sudo easy_install pip
else # ubuntu
  # Check os support if >= 16 just use apt
  # https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-docker-ce
  # sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
  sudo apt-get update
  sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common ntpdate
  curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -
  sudo apt-key fingerprint 0EBFCD88
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt-get update
  apt-cache madison docker-ce
  sudo apt-get install -y docker-ce
  # Let's setup so that we can use docker without sudo
  echo "Setting up docker ..."
  sudo gpasswd -a ubuntu docker
  /usr/bin/newgrp docker <<EONG
EONG
  echo "Restarting docker ..."
  sudo service docker restart
  # Useful if we need Python 2.7
  # sudo apt-get install -y python-setuptools
  # Let's use the default Python3 env
  echo "Symbolic Linking to Python 3 ..."
  sudo ln -sf /usr/bin/python3 /usr/bin/python
  sudo apt-get install -y python-pip
fi

# Fall back to pinned version (no fallback for ppc)
#if [ "$?" == "1" ]; then
  #yum install --setopt=obsoletes=0 -y docker-ce-17.03.2.ce-1.el7.centos.x86_64 docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch
#fi

echo "Looping through workers ..."
for ((i=0; i < $NUM_WORKERS; i++)); do
  # Install docker & python on worker
  if [ "${OS}" == "rhel" ]; then
    echo "Installing for RHEL ...."
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo yum install -y yum-utils device-mapper-persistent-data lvm2
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo yum-config-manager -y --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo yum install -y docker-ce
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo yum install -y python-setuptools
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo easy_install pip
  else # ubuntu
    echo "Installing for Ubuntu ...."
    # ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo apt-get update
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common ntpdate
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} "curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -"
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo apt-key fingerprint 0EBFCD88
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo add-apt-repository "\"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\""
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo apt-get update
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} apt-cache madison docker-ce
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo apt-get install -y docker-ce
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo gpasswd -a ubuntu docker
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} /usr/bin/newgrp docker <<EONG
EONG
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo service docker restart
    # ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo apt-get install -y python-setuptools
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo ln -sf /usr/bin/python3 /usr/bin/python
    ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo apt-get install -y python-pip
  fi
done
