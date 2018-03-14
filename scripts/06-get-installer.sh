#!/bin/bash
set -e
# Get the variables
source 00-variables.sh

if [[ -z "${INCEPTION_TAR_FILEPATH}" ]]; then
  sudo service docker start
  sudo docker pull ibmcom/icp-inception${INCEPTION_TAG}:${INCEPTION_VERSION}
else
  echo "A local ICP Tar File has been provided.  We will load the installation from ${INCEPTION_TAR_FILEPATH}"
  echo "Patience will be required ... the loading of the tar file can take while.  Go grab a cup of coffee or a beer!"
  sudo service docker start
  tar -xf "${INCEPTION_TAR_FILEPATH}" -O | sudo docker load
fi

  # Let's make sure no legacy stuff is left behind from prior installs
  sudo rm -rf /opt/ibm-cloud-private-${INCEPTION_VERSION}-old
  sudo mv /opt/ibm-cloud-private-${INCEPTION_VERSION} /opt/ibm-cloud-private-${INCEPTION_VERSION}-old 2>/dev/null; true
  sudo mkdir -p /opt/ibm-cloud-private-${INCEPTION_VERSION} 2>/dev/null; true
  sudo chown $USER /opt/ibm-cloud-private-${INCEPTION_VERSION}
  cd /opt/ibm-cloud-private-${INCEPTION_VERSION}

  sudo docker run -v $(pwd):/data -e LICENSE=accept ibmcom/icp-inception${INCEPTION_TAG}:${INCEPTION_VERSION} cp -r cluster /data

if [[ -n "${INCEPTION_TAR_FILEPATH}" ]]; then
  echo "Copying ICP Tar File into cluster/images directory"
  sudo mkdir -p /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/images
  sudo cp "${INCEPTION_TAR_FILEPATH}" /opt/ibm-cloud-private-${INCEPTION_VERSION}/cluster/images
fi
