#!/bin/bash

# Get the variables
source 00-variables.sh

cd /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster

sudo docker run -e LICENSE=accept --net=host -t -v "$(pwd)":/installer/cluster ibmcom/icp-inception${INCEPTION_TAG}:${INCEPTION_VERSION} install
