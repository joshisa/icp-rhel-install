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

CAM_TARBALL_PATH=https://path/to/some.tar.gz
wget -O /tmp/cam/cam.tar.gz ${CAM_TARBALL_PATH} # --user <OPTIONAL> --password <OPTIONAL>
bx pr load-ppa-archive --namespace services --archive /tmp/cam/cam.tar.gz

echo -e "${beers}   Congrats.  After synchronizing your cluster repositories, you should see the CAM chart available within the catalog"
# Cleanup
#rm -rf /tmp/cam
