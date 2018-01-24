#!/usr/bin/env bash

set -e
set -u

source 00-variables.sh

kubectl create secret docker-registry myregistrykey --docker-server=mycluster.icp:8500 --docker-username="${user}" --docker-password="${pw}" --docker-email="${email}"
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "myregistrykey"}]}'
