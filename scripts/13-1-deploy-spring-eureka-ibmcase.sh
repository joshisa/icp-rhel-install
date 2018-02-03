#!/bin/bash
# ----------------------------------------------------------------------------------------------------\\
# Description:
#   Setup and deploy a simple ASP.NET and .NET Core sample into IBM Cloud Private
# ----------------------------------------------------------------------------------------------------\\
set -e

# Get the variables
source 00-variables.sh
rm -rf /tmp/spring
mkdir -p /tmp/spring

git clone https://github.com/ibm-cloud-architecture/refarch-cloudnative-spring.git /tmp/spring
kubectl create -f /tmp/spring/refarch-cloudnative-spring/rabbitmq/rabbitmq-pvc.yaml
# Work in progress ...
# ./10-waiter.sh default

# PORT=$(kubectl get svc kube-dotnet -n default -o jsonpath='{.spec.ports[*].nodePort}')
# echo ""
# echo "Congrats.  You can now browse to http://${PUBLIC_IP}:$PORT to view your ASP.NET deployment"
# echo "Additionally, you can browse to the logs view of the dotnetappprod job or via CLI "
# echo ""
# echo "     EXAMPLE:  kubectl logs jobs/kube-dotnet-prod"
# echo ""
