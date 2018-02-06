#!/bin/bash
# ----------------------------------------------------------------------------------------------------\\
# Description:
#   Setup and deploy Microclimate with persistence into IBM Cloud Private
# ----------------------------------------------------------------------------------------------------\\
set -e

# Get the variables
source 00-variables.sh
rm -rf /tmp/microclimate
mkdir -p /tmp/microclimate

AVAILABLE_PV=$(kubectl get pv -o wide | grep "5Gi" | grep "Available" | grep "RWO" | wc -l)
curl -Lo /tmp/microclimate.zip https://microclimate-dev2ops.github.io/download/microclimate.zip
sudo apt-get install -y unzip
unzip -o -d /tmp /tmp/microclimate.zip

if [ "$AVAILABLE_PV" -eq "0" ]; then
   echo "There are no registered persistent volumes of 5Gi RWO that is Available within the default namespace"
   echo "A PV of 5Gi or larger is required for enabling persistence with the microclimate environment"
   echo "Executing kubectl get pv -o wide ..."
   echo ""
   kubectl get pv -o wide
   echo ""
   exit 1
else
   helm install --name microclimate --set persistence.enabled=true /tmp/microclimate/chart/microclimate
fi

./10-waiter.sh "pods" "default" "0/1"

# Cleanup
rm /tmp/microclimate.zip
rm -rf /tmp/microclimate

PORT=$(kubectl get svc microclimate -n default -o jsonpath='{.spec.ports[*].nodePort}')
echo "When the pods are deployed, you may browse to http://${PUBLIC_IP}:${PORT} to access your microclimate instance"
