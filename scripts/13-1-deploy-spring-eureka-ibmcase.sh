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

# git clone https://github.com/ibm-cloud-architecture/refarch-cloudnative-spring.git /tmp/spring
# Temporarily using patched fork for rabbitmq erlang issue until PR accepted
git clone https://github.com/joshisa/refarch-cloudnative-spring.git /tmp/spring

# Initiating attempt to patch first valid pv
AVAILABLE_PV=$(kubectl get pv -o wide | grep -E "([2-9][0-9])Gi" | grep "Available" | grep "RWO" | wc -l)
if [ "${AVAILABLE_PV}" -eq "0" ]; then
   echo "There are no registered persistent volumes of 20Gi RWO that are Available"
   echo "Please consider creating a PV with RWO of 20Gi or larger to satisfy the rabbit MQ requirement"
   exit 1
else
   FIRST_ELIGIBLE=$(kubectl get pv -o wide | grep -E "([2-9][0-9])Gi" | grep "Available" | grep "RWO" | head -1 | awk '{print $1}')
   kubectl patch pv/${FIRST_ELIGIBLE} -n default -p '{"spec":{"storageClassName":"default"}}'
   kubectl create -f /tmp/spring/rabbitmq/rabbitmq-pvc.yaml
   ./10-waiter.sh "pvc" "default" "Pending"
fi

kubectl create -f /tmp/spring/rabbitmq/rabbitmq-deployment.yaml

# Note that the deployment above creates the following RabbitMQ credentials:
#
#     Username: guest
#     Password: guest
#

kubectl create -f /tmp/spring/rabbitmq/rabbitmq-service.yaml


helm install --name spring-stack ibmcase-spring/spring-stack \
--set global.rabbitmq.host=rabbitmq \
--set global.rabbitmq.username=guest \
--set global.rabbitmq.password=guest \
--set spring-config-server.spring.cloud.config.server.git.uri=https://github.com/ibm-cloud-architecture/fortune-teller \
--set spring-config-server.spring.cloud.config.server.git.searchPaths=configuration \
--set spring-eureka-server.service.type=NodePort

./10-waiter.sh "pods" "default" "0/1"

PORT=$(kubectl get svc spring-stack-spring-eureka-server -n default -o jsonpath='{.spec.ports[*].nodePort}')
echo ""
echo "Congrats.  You can now browse to http://${PUBLIC_IP}:$PORT to view your Eureka deployment"
echo ""
