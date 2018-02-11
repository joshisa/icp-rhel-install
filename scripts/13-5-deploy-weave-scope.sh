#!/bin/bash
# ----------------------------------------------------------------------------------------------------\\
# Description:
#   Setup and deploy Microclimate with persistence into IBM Cloud Private
# ----------------------------------------------------------------------------------------------------\\
set -e

# Get the variables
source 00-variables.sh

kubectl apply -f "https://cloud.weave.works/k8s/scope.yaml?k8s-version=$(kubectl version | base64 | tr -d '\n')"
./10-waiter.sh "pods" "weave" "0/1"

# Change svc from ClusterIP to NodePort
kubectl get svc weave-scope-app -n weave -o yaml | sed 's/ClusterIP/NodePort/' | kubectl replace -f -
PORT=$(kubectl get svc weave-scope-app -n weave -o jsonpath='{.spec.ports[*].nodePort}')
echo "When the pods are deployed, you may browse to http://${PUBLIC_IP}:${PORT} to access your weave scope instance"
