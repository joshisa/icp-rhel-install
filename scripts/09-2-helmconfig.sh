#!/usr/bin/env bash
#  Purpose
#  This scripts sets up the Helm CLI
#

set -e
set -u

HELMVERSION=2.7.2
curl -Lo /tmp/helm.tar.gz https://storage.googleapis.com/kubernetes-helm/helm-v${HELMVERSION}-linux-amd64.tar.gz
tar -zxvf /tmp/helm.tar.gz -C /tmp
sudo mv /tmp/linux-amd64/helm /usr/local/bin/helm
chmod +x /usr/local/bin/helm

helm init --upgrade
helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable/
helm repo add ibmcase https://raw.githubusercontent.com/ibm-cloud-architecture/refarch-cloudnative-kubernetes/master/docs/charts/bluecompute-ce
helm repo add ibmcase-spring https://raw.githubusercontent.com/ibm-cloud-architecture/refarch-cloudnative-spring/master/docs/charts/
