#!/bin/bash
# ----------------------------------------------------------------------------------------------------\\
# Description:
#   Setup and deploy Cloud Automation Manager into IBM Cloud Private
# ----------------------------------------------------------------------------------------------------\\
set -e

# Get the variables
source 00-variables.sh

rm -rf /tmp/cam
mkdir -p /tmp/cam


#####################################################
# PLEASE UNCOMMENT DEPENDING ON YOUR RESPECTIVE OS  #
#
# Q: Why is this section needed?
# A: Without this, during the CAM image push step,
#    you could encounter an error as follows ...
#    "Error response from daemon: Get https://mycluster.icp:8500/v2/: x509: certificate signed by unknown authority"
#####################################################

dockerRegistry='mycluster.icp'
dockerRegistryPort='8500'
# ICPUSER="admin"  Uncomment if no 00-variables file is sourced

#sudo echo "$masterNode $dockerRegistry" | sudo tee -a /etc/hosts > /dev/null
openssl s_client -showcerts -connect "$dockerRegistry:$dockerRegistryPort" </dev/null 2>/dev/null|openssl x509 -outform PEM >$dockerRegistry.docker.crt

# FOR OSX
# sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $dockerRegistry.docker.crt
# sh -c "osascript -e 'quit app \"Docker\"' && open -a Docker"
# Need to wait for Docker for Mac to restart
# sleep 25

# FOR LINUX
# sudo mkdir -p "/etc/docker/certs.d/$dockerRegistry:$dockerRegistryPort"
# sudo cp "$dockerRegistry.docker.crt" "/etc/docker/certs.d/$dockerRegistry:$dockerRegistryPort"
# sudo service docker restart (OPTIONAL)

docker login -u $ICPUSER "https://$dockerRegistry:$dockerRegistryPort"
# Terminal prompt for password against user provided.  For automation, you
# can consider using the less secure method of providing the password within
# the command itself.

CAM_TARBALL_PATH=https://path/to/some.tar.gz
CAM_FILE=${CAM_TARBALL_PATH##*/}
wget -O /tmp/cam/${CAM_FILE} ${CAM_TARBALL_PATH} # --user <OPTIONAL> --password <OPTIONAL>
bx pr load-ppa-archive --namespace services --archive /tmp/cam/${CAM_FILE}

echo -e "${beers}   Congrats.  After synchronizing your cluster repositories, you should see the CAM chart available within the catalog"
# Cleanup
#rm -rf /tmp/cam
