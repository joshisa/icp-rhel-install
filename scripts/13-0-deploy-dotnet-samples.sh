#!/bin/bash
# ----------------------------------------------------------------------------------------------------\\
# Description:
#   Setup and deploy a simple ASP.NET and .NET Core sample into IBM Cloud Private
# ----------------------------------------------------------------------------------------------------\\
set -e

# Get the variables
source 00-variables.sh
rm -rf /tmp/dotnet
mkdir -p /tmp/dotnet

docker login mycluster.icp:8500 -u $ICPUSER -p $ICPPW
git clone https://github.com/joshisa/dnet /tmp/dotnet
docker build -t mycluster.icp:8500/default/aspnetapp:demo /tmp/dotnet/dotnet-docker-samples/aspnetapp
docker push mycluster.icp:8500/default/aspnetapp:demo
kubectl create -f /tmp/dotnet/aspdotnetkube.yml

docker build -t mycluster.icp:8500/default/dotnetappprod:demo /tmp/dotnet/dotnet-docker-samples/dotnetapp-prod
docker push mycluster.icp:8500/default/dotnetappprod:demo
kubectl create -f /tmp/dotnet/prod-dot-net-kube.yml

./10-waiter.sh "pods" "default" "0/1"

PORT=$(kubectl get svc kube-dotnet -n default -o jsonpath='{.spec.ports[*].nodePort}')
echo ""
echo "Congrats.  You can now browse to http://${PUBLIC_IP}:$PORT to view your ASP.NET deployment"
echo "Additionally, you can browse to the logs view of the dotnetappprod job or via CLI "
echo ""
echo "     EXAMPLE:  kubectl logs jobs/kube-dotnet-prod"
echo ""
