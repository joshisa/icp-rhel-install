#!/bin/bash
# ----------------------------------------------------------------------------------------------------\\
# Description:
#   Setup and deploy Microclimate with persistence into IBM Cloud Private
# ----------------------------------------------------------------------------------------------------\\
set -e

# Get the variables
source 00-variables.sh

rm -rf /tmp/cam
mkdir -p /tmp/cam

CAM_TARBALL_PATH=http://some/url/path.tar.gz

curl -Lo /tmp/cam/cam.tar.gz ${CAM_TARBALL_PATH}
bx pr load-ppa-archive --archive /tmp/cam/cam.tar.gz


#PORT=$(kubectl get svc weave-scope-app -n weave -o jsonpath='{.spec.ports[*].nodePort}')
#echo "When the pods are deployed, you may browse to http://${PUBLIC_IP}:${PORT} to access your weave scope instance"
