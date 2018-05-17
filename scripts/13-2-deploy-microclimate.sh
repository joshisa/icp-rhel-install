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

AVAILABLE_PV=$(kubectl get pv -o wide | grep "8Gi" | grep "Available" | grep "RWO" | wc -l)
curl -Lo /tmp/microclimate.zip https://microclimate-dev2ops.github.io/download/microclimate-18.04.zip
sudo apt-get install -y unzip
unzip -o -d /tmp /tmp/microclimate.zip

kubectl delete secret microclimate-registry-secret --ignore-not-found=true
kubectl create secret docker-registry microclimate-registry-secret --docker-server=mycluster.icp:8500 --docker-username="${ICPUSER}" --docker-password="${ICPPW}" --docker-email="${ICPEMAIL}" -n default
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "microclimate-registry-secret"}]}' -n default

if [ "$AVAILABLE_PV" -eq "0" ]; then
   echo "There are no registered persistent volumes of 8Gi RWX that is Available within the default namespace"
   echo "A PV of 8Gi or larger is required for enabling persistence with the microclimate environment"
   echo "Executing kubectl get pv -o wide ..."
   echo ""
   kubectl get pv -o wide
   echo ""
   exit 1
else
   helm install --tls --name microclimate --namespace default --set jenkins.Master.HostName=jenkins.${PUBLIC_IP}.nip.io --set persistence.enabled=true /tmp/microclimate-18.04/stable/ibm-microclimate
fi

./10-waiter.sh "pods" "default" "0/1"

# Cleanup
rm /tmp/microclimate.zip
rm -rf /tmp/microclimate

PORT=$(kubectl get svc microclimate -n default -o jsonpath='{.spec.ports[*].nodePort}')
echo "When the pods are deployed, you may browse to http://${PUBLIC_IP}:${PORT} to access your microclimate instance"
