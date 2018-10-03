#!/bin/bash
# ----------------------------------------------------------------------------------------------------\\
# Description:
#   A basic script port to extract necessary certificates and allow remote login
#   on an ICP Cluster's docker image registry
#
#   usage ./12-3-remote-docker-login.sh
#
#   Options:
#       None
#
#   Example:   ./12-3-remote-docker-login.sh
#    Result:   
#
#
# ----------------------------------------------------------------------------------------------------\\

##########
# Colors##
##########
Green='\x1B[0;32m'
Red='\x1B[0;31m'
Yellow='\x1B[0;33m'
Cyan='\x1B[0;36m'
no_color='\x1B[0m' # No Color
beer='\xF0\x9f\x8d\xba'
delivery='\xF0\x9F\x9A\x9A'
beers='\xF0\x9F\x8D\xBB'
eyes='\xF0\x9F\x91\x80'
cloud='\xE2\x98\x81'
crossbones='\xE2\x98\xA0'
litter='\xF0\x9F\x9A\xAE'
fail='\xE2\x9B\x94'
harpoons='\xE2\x87\x8C'
tools='\xE2\x9A\x92'
present='\xF0\x9F\x8E\x81'
#############

source ./00-variables.sh

dockerRegistry='mycluster.icp'
dockerRegistryPort='8500'

sudo echo "${MASTER_IP} ${dockerRegistry}" | sudo tee -a /etc/hosts > /dev/null
openssl s_client -showcerts -connect "$dockerRegistry:$dockerRegistryPort" </dev/null 2>/dev/null|openssl x509 -outform PEM >$dockerRegistry.docker.crt
# FOR OSX
# sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $dockerRegistry.docker.crt
# sh -c "osascript -e 'quit app \"Docker\"' && open -a Docker"
# Need to wait for Docker for Mac to restart
# sleep 25

# FOR LINUX
echo -e "${tools}  Restarting docker to register the new extracted system certificate ..."
sudo mkdir -p "/etc/docker/certs.d/${dockerRegistry}:${dockerRegistryPort}"
sudo cp "$dockerRegistry.docker.crt" "/etc/docker/certs.d/${dockerRegistry}:${dockerRegistryPort}"
sudo service docker restart

echo -e "\n"
echo -e "Logging into the IBM Cloud Private v2 Registry ..."
docker login -u ${ICPUSER} "https://${dockerRegistry}:${dockerRegistryPort}"
echo -e "\n"
echo -e "${beers}   Congrats!  Docker Registry Login Successful"
