#!/usr/bin/env bash
#  Purpose
#  This scripts sets up the Bluemix CLI
#  Tested on Ubuntu 16.04 x86 system.
#

set -e
set -u
shopt -s expand_aliases

source 00-variables.sh
BLUEMIXCLIVERSION=0.6.4
curl -Lo /tmp/clibluemix.tar.gz https://clis.ng.bluemix.net/download/bluemix-cli/${BLUEMIXCLIVERSION}/linux64
tar -zxf /tmp/clibluemix.tar.gz -C /tmp
sudo /tmp/Bluemix_CLI/install_bluemix_cli

curl --insecure -Lo /tmp/icpcli https://${PUBLIC_IP}:8443/api/cli/icp-linux-amd64
bx plugin install /tmp/icpcli
bx plugin install dev -r Bluemix

# Cleanup
sudo rm /tmp/clibluemix.tar.gz
sudo rm -rf /tmp/Bluemix_CLI
sudo rm /tmp/icpcli

bx plugin show icp
echo ""
bx pr login -a https://${PUBLIC_IP}:8443 --skip-ssl-validation -u admin -p admin -c id-mycluster-account
echo ""
bx pr
