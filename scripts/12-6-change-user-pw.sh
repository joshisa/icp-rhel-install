#!/usr/bin/env bash

USAGE="Usage: ./12-6-change-user-pw.sh newusername newpw\n
\tnewusername:\tAssignment or reuse of username  \n
\tnewpw:\t\tAssignment of new password \n"

if [ $# -lt 2 ]; then
    echo -e $USAGE
    exit 1
fi

RAWNEWUSER="${1}"
NEWUSER=$(echo -n "${1}" | base64)
NEWPW=$(echo -n "${2}" | base64)

echo -e "Patching platform-auth-idp-credentials secrets file with new entries ..."
kubectl patch -n kube-system secrets platform-auth-idp-credentials -p '{"data":{"admin_password":"'${NEWPW}'","admin_username":"'${NEWUSER}'"}}'

echo -e "Restarting authentication service(s) ..."
kubectl -n kube-system delete pods -l k8s-app=auth-idp

echo -e "Patching clusterrolebinding for cluster admin..."
kubectl patch clusterrolebinding oidc-admin-binding -p '{"subjects":[{"apiGroup":"rbac.authorization.k8s.io","kind":"User","name":"https://mycluster.icp:9443/oidc/endpoint/OP#'${RAWNEWUSER}'"}]}'

echo -e "Run the following commands to verify auth services are back online..."
echo -e "kubectl -n kube-system get pods -l k8s-app=auth-idp"
echo -e ""
echo -e "kubectl -n kube-system get pods -l k8s-app=auth-pdp"
