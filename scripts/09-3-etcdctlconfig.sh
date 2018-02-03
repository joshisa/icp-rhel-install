#!/usr/bin/env bash
#  Purpose
#  This scripts sets up the Helm CLI
#

set -e
set -u

ETCDCTLVERSION=3.3.0
curl -Lo /tmp/etcdctl.tar.gz https://github.com/coreos/etcd/releases/download/v${ETCDCTLVERSION}/etcd-v${ETCDCTLVERSION}-linux-amd64.tar.gz
tar -zxf /tmp/etcdctl.tar.gz -C /tmp
sudo mv /tmp/etcd-v${ETCDCTLVERSION}-linux-amd64/etcdctl /usr/local/bin/etcdctl
chmod +x /usr/local/bin/etcdctl

# Cleanup
sudo rm -rf /tmp/etcd-v${ETCDCTLVERSION}-linux-amd64
sudo rm /tmp/etcdctl.tar.gz

ip=$(ps -ef | grep -Po "(?<=advertise-client-urls\=)https:\/\/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:4001");

echo ""
echo "${ip} is your etcd endpoint(s)"
echo ""

echo "Executing command:"
echo "    etcdctl --cert-file=/etc/cfc/conf/etcd/client.pem --key-file=/etc/cfc/conf/etcd/client-key.pem --ca-file=/etc/cfc/conf/etcd/ca.pem --endpoints=${ip} cluster-health"
echo ""
echo "Result:"
etcdctl --cert-file=/etc/cfc/conf/etcd/client.pem --key-file=/etc/cfc/conf/etcd/client-key.pem --ca-file=/etc/cfc/conf/etcd/ca.pem --endpoints=$ip cluster-health

echo ""
echo "Executing command:"
echo "     etcdctl --cert-file=/etc/cfc/conf/etcd/client.pem --key-file=/etc/cfc/conf/etcd/client-key.pem --ca-file=/etc/cfc/conf/etcd/ca.pem --endpoints=${ip} member list"
echo ""
echo "Result:"
etcdctl --cert-file=/etc/cfc/conf/etcd/client.pem --key-file=/etc/cfc/conf/etcd/client-key.pem --ca-file=/etc/cfc/conf/etcd/ca.pem --endpoints=$ip member list
echo ""
