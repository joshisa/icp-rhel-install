#!/usr/bin/env bash
# ##################################################
#
version="1.0.0"              # Sets version variable
#
# DESCRIPTION:  kubetube.sh - Helper script that deploys
#               kubetube into specific namespaces
#
# HISTORY:
#
# * DATE - v1.0.0  - First Creation
# 
# ##################################################

export ICPUSER=admin
export ICPPW=admin
export ICPEMAIL=admin@foo.com
# Ingress IP Host
export ICPHOST="${PUBLIC_IP}"
export KUBETUBE_ADMIN_EMAIL=<some-user>@gmail.com
export KUBETUBE_ADMIN_PW=
# You can generate your own KEYBASE string using "openssl rand -hex 32"
export KEYBASE=$(openssl rand -hex 32)
# whotube should ideally match the target namespace for the workload
export whotube="kubetube"
export NAMESPACE="${whotube}"


##############
# Tablestakes
#kubectl create namespace "${NAMESPACE}"

# Gotta create docker pull secrets and patch
#kubectl create secret docker-registry myregistrykey --docker-server=mycluster.icp:8500 --docker-username="${ICPUSER}" --docker-password="${ICPPW}" --docker-email="${ICPEMAIL}" -n "${whotube}"
#kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "myregistrykey"}]}' -n "${whotube}"

#git clone https://github.com/joshisa/asciinema-k8s -b hard_slash
#cd asciinema-k8s && docker build -t mycluster.icp:8500/default/kubetube:1.0.0 .
#docker push mycluster.icp:8500/default/kubetube:1.0.0

# Let's get on with it.
# https://github.com/kubernetes/helm/pull/3599 - relevant PR/bug

# Need to pre-create two Persisted Volumes:  2 Gbi RWO and 5 Gbi RWO to facilitate PostGres DB and Redis.

# Important to keep track of the port, scheme and ingress enablement.  For example, if ingress is enabled - then 443 and https is probably the right complements
helm install --tls --set ingress.enabled="true" --set environment.airgap=\"false\" --set postgresql.persistence.existingClaim="${whotube}-claim1" --set ingress.host="${ICPHOST}" --set ingress.path="/${whotube}" --set service.scheme="https" --set service.port=":443" --set image.name="default/kubetube" --set image.tag=1.0.0 --set secrets.username="${KUBETUBE_ADMIN_EMAIL}" --set secrets.password="${KUBETUBE_ADMIN_PW}" --set secrets.keybase="${KEYBASE}" kubetube/chart --name "${whotube}" --namespace "${whotube}"

watch -n 2 kubectl get pods -n "${NAMESPACE}"
