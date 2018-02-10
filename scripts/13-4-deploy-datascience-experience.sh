#!/bin/bash
# ----------------------------------------------------------------------------------------------------\\
# Description:
#   Setup and deploy DSX Dev edition into IBM Cloud Private
# ----------------------------------------------------------------------------------------------------\\
set -e

# Get the variables
source 00-variables.sh
rm -rf /tmp/dsx
mkdir -p /tmp/dsx

AVAILABLE_PV=$(kubectl get pv -o wide | grep -E "([1-9]|[1-9][0-9])Gi" | grep "Available" | grep "RWX" |wc -l)

if [ "$AVAILABLE_PV" -eq "0" ]; then
   echo "There are no registered persistent volumes of 1Gi RWX that is Available within the default namespace"
   echo "A PV of 1Gi or larger is required for a successful deployment of DSX-Dev"
   echo "Executing kubectl get pv -o wide ..."
   echo ""
   kubectl get pv -o wide
   echo ""
   echo "Consider editing or creating a pv with a size of 1G RWX and then try this script again"
   echo ""
   exit 1
fi

#DSX-DEV requires that your persistent volume have an assign-to label of user-home
#Single line patch to first PV that meets the criteria
DSXPV=$(kubectl get pv | grep -E "([1-9]|[1-9][0-9])Gi" | grep "Available" | grep "RWX" | head -1 | awk '{print $1}')
kubectl patch pv/${DSXPV} -n default -p '{"metadata":{"labels":{"assign-to":"user-home"},"name":"'${DSXPV}'"}}'

helm install --namespace default --name dsx-stack ibm-dsx-dev
./10-waiter.sh "pods" "default" "0/1"

PORT=$(kubectl get svc dsx-ux -n default -o jsonpath='{.spec.ports[*].nodePort}')
echo ""
echo "Congrats.  You can now browse to http://${PUBLIC_IP}:$PORT to view your DSX-DEV deployment"
echo ""
