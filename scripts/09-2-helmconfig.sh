#!/usr/bin/env bash
#  Purpose
#  This scripts sets up the Helm CLI
#

set -e
set -u

HELMVERSION=2.7.2
curl -k -Lo /tmp/helm https://mycluster.icp:8443/helm-api/cli/linux-amd64/helm --header "Authorization: $(bx pr tokens | grep "Access token:" | cut -d' ' -f3- | sed -e 's/^[[:space:]]*//')"
chmod +x /tmp/helm
sudo mv /tmp/helm /usr/local/bin/helm

helm init --upgrade
helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable/
helm repo add ibmcase https://raw.githubusercontent.com/ibm-cloud-architecture/refarch-cloudnative-kubernetes/master/docs/charts/bluecompute-ce
helm repo add ibmcase-spring https://raw.githubusercontent.com/ibm-cloud-architecture/refarch-cloudnative-spring/master/docs/charts/
