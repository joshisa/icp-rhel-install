#!/bin/bash

# Get the variables
source 00-variables.sh

if [[ -z "${INCEPTION_TAR_FILEPATH}" ]]; then
  sudo service docker start
  sudo docker pull ibmcom/icp-inception${INCEPTION_TAG}:${INCEPTION_VERSION}
else
  echo "A local ICP Tar File has been provided.  We will load the installation from ${INCEPTION_TAR_FILEPATH}"
  echo "Patience will be required ... the loading of the tar file can take while.  Go grab a cup of coffee or a beer!"
  sudo service docker start
  tar -xf "${INCEPTION_TAR_FILEPATH}" -O | docker load
fi

  sudo mkdir /opt/ibm-cloud-private-${INCEPTION_VERSION}
  sudo chown $USER /opt/ibm-cloud-private-${INCEPTION_VERSION}
  cd /opt/ibm-cloud-private-${INCEPTION_VERSION}

  sudo docker run -v $(pwd):/data -e LICENSE=accept ibmcom/icp-inception${INCEPTION_TAG}:${INCEPTION_VERSION} cp -r cluster /data
