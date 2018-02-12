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
CAM_FILE=${CAM_TARBALL_PATH##*/}
wget -O /tmp/cam/${CAM_FILE} ${CAM_TARBALL_PATH} # --user <OPTIONAL> --password <OPTIONAL>
bx pr load-ppa-archive --namespace services --archive /tmp/cam/${CAM_FILE}

echo -e "${beers}   Congrats.  After synchronizing your cluster repositories, you should see the CAM chart available within the catalog"
# Cleanup
#rm -rf /tmp/cam
