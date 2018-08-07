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

helm init --client-only
helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable/
helm repo add ibmcase https://raw.githubusercontent.com/ibm-cloud-architecture/refarch-cloudnative-kubernetes/master/docs/charts/bluecompute-ce
helm repo add ibmcase-spring https://raw.githubusercontent.com/ibm-cloud-architecture/refarch-cloudnative-spring/master/docs/charts/

ibmcloud pr cluster-config $(bx pr clusters | awk 'FNR == 3 {print $1}') 
CERTCNT=$(find ~/.helm -type f -name "cert.pem" | wc -l)
KEYCNT=$(find ~/.helm -type f -name "key.pem" | wc -l)

if [[ "${CERTCNT}" -eq "0" ]]; then
  echo -e "Something went wrong with the cluster-config command.  Manually patching helm home with cert.pem"
  cp $(find /opt -path "*/cfc-certs/helm/*" -type f -name "admin.crt") ~/.helm/cert.pem
fi

if [[ "${KEYCNT}" -eq "0" ]]; then
  echo -e "Something went wrong with the cluster-config command.  Manually patching helm home with key.pem"
  cp $(find /opt -path "*/cfc-certs/helm/*" -type f -name "admin.key") ~/.helm/key.pem
fi

helm version --tls

# Hint ... if you cannot connect to tiller
# Reset your ICP tiller deploy ... by doing these two steps on your boot/master node
#
# kubectl delete deploy tiller-deploy -n kube-system
# kubectl apply --force --overwrite=true -f $(find /opt -name tiller.yaml)
