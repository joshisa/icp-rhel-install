#!/usr/bin/env bash

set -e
set -u
#set -x

echo "One stop shop script for deploying ICP if you have line-of-sight to all IPs for the cluster"
./00-variables.sh
./01-update-hosts.sh
./01-1-passwordless-ssh.sh
./01-2-bind-mounts.sh
./02-ssh-setup.sh
./03-install-packages.sh
./04-configure-os.sh
./05-firewall-config.sh
./06-get-installer.sh
./07-configure-installer.sh
./08-install.sh
./09-kubeconfig.sh
./waiter.sh
