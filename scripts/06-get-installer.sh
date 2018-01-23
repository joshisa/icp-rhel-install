#!/bin/bash

# Get the variables
source 00-variables.sh

sudo service docker start
sudo docker pull ibmcom/icp-inception${INCEPTION_TAG}:${INCEPTION_VERSION}

sudo mkdir /opt/ibm-cloud-private-${INCEPTION_VERSION}
sudo chown $USER /opt/ibm-cloud-private-${INCEPTION_VERSION}
cd /opt/ibm-cloud-private-${INCEPTION_VERSION}

sudo docker run -v $(pwd):/data -e LICENSE=accept ibmcom/icp-inception${INCEPTION_TAG}:${INCEPTION_VERSION} cp -r cluster /data
