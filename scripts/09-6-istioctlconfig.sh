#!/usr/bin/env bash
#  Purpose
#  This scripts sets up the istioctl CLI
#  Tested on Ubuntu 16.04 x86 system.
#

set -e
set -u
shopt -s expand_aliases

ISTIO_VERSION=0.7.1
sudo rm /usr/local/bin/istioctl
curl -L https://git.io/getLatestIstio | ISTIO_VERSION="${ISTIO_VERSION}" sh -
sudo mv istio-"${ISTIO_VERSION}"/bin/istioctl /usr/local/bin/
# Cleanup
sudo rm -rf istio-"${ISTIO_VERSION}"
