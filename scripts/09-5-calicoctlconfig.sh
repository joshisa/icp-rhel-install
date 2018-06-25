#!/usr/bin/env bash
#  Purpose
#  This scripts sets up the CALICOCTL CLI
#  Tested on Ubuntu 16.04 x86 system.
#

set -e
set -u
shopt -s expand_aliases

source 00-variables.sh

CALICOCTLVERSION=3.1.3
CALICOCTL_CFG_PATH=/etc/calico/calicoctl.cfg
sudo rm -rf /etc/calico
sudo mkdir -p /etc/calico

curl -Lo /tmp/calicoctl https://github.com/projectcalico/calicoctl/releases/download/v${CALICOCTLVERSION}/calicoctl
chmod +x /tmp/calicoctl
sudo mv /tmp/calicoctl /usr/local/bin/calicoctl


ip=$(ps -ef | grep -Po "(?<=advertise-client-urls\=)https:\/\/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:4001");
#echo "${ip} is your etcd endpoint(s)"

# Build config file for calicoctl
touch calicoctl.cfg
echo "apiVersion: projectcalico.org/v3" >> calicoctl.cfg
echo "kind: CalicoAPIConfig" >> calicoctl.cfg
echo "metadata:" >> calicoctl.cfg
echo "spec:" >> calicoctl.cfg
echo "  etcdEndpoints: ${ip}" >> calicoctl.cfg
echo "  etcdKeyFile: /etc/cfc/conf/etcd/client-key.pem" >> calicoctl.cfg
echo "  etcdCertFile: /etc/cfc/conf/etcd/client.pem" >> calicoctl.cfg
echo "  etcdCACertFile: /etc/cfc/conf/etcd/ca.pem" >> calicoctl.cfg
echo "  datastoreType: \"kubernetes\"" >> calicoctl.cfg
echo "  kubeconfig: \"/home/${SSH_USER}/.kube/config\"" >> calicoctl.cfg

sudo mv calicoctl.cfg /etc/calico

echo "Executing command:  calicoctl get nodes -o wide"
calicoctl get nodes -o wide
echo ""
echo "Executing command:  sudo calicoctl node status"
sudo calicoctl node status
echo ""
echo "Executing command:  calicoctl get pool"
calicoctl get pool
echo ""
echo "Executing command:  calicoctl get wep"
calicoctl get wep
echo ""
echo "Executing command:  calicoctl get profile"
calicoctl get profile
echo ""
echo "Executing command:  calicoctl get policy"
calicoctl get policy
echo ""
