#!/bin/bash
# ----------------------------------------------------------------------------------------------------\\
# Description:
#   Setup and deploy Microclimate with persistence into IBM Cloud Private
# ----------------------------------------------------------------------------------------------------\\
set -e

# Get the variables
source 00-variables.sh
rm -rf /tmp/phpmyfaq
mkdir -p /tmp/phpmyfaq

git clone https://github.com/joshisa/docker-phpmyfaq /tmp/phpmyfaq
docker login mycluster.icp:8500 --username $ICPUSER --password $ICPPW
docker build -t mycluster.icp:8500/default/phpmyfaq:2.9.9 /tmp/phpmyfaq/ 
docker push mycluster.icp:8500/default/phpmyfaq:2.9.9
kubectl run icpfaq --image=mycluster.icp:8500/default/phpmyfaq:2.9.9
kubectl expose deployment icpfaq --type=NodePort --port=80 --target-port=80
kubectl autoscale deployment icpfaq --min=1 --max=3
./10-waiter.sh "pods" "default" "0/1"
# Cleanup
rm -rf /tmp/phpmyfaq

PORT=$(kubectl get svc icpfaq -n default -o jsonpath='{.spec.ports[*].nodePort}')
echo "When the pods are deployed, you may browse to http://${PUBLIC_IP}:${PORT} to access your phpmyFAQ instance"
