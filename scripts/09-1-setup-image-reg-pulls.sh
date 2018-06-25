#!/usr/bin/env bash

set -e
set -u

source 00-variables.sh

kubectl create secret docker-registry myregistrykey --namespace hygieia --docker-server=mycluster.icp:8500 --docker-username="${ICPUSER}" --docker-password="${ICPPW}" --docker-email="${ICPEMAIL}"
kubectl patch serviceaccount default --namespace hygieia -p '{"imagePullSecrets": [{"name": "myregistrykey"}]}'
