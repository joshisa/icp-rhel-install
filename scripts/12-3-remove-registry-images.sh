#!/bin/bash
# ----------------------------------------------------------------------------------------------------\\
# Description:
#   A basic script port to delete registry images on an ICP Cluster
#   Fork of https://gist.github.com/mohamed-el-habib/26d26dddaf3dcefcc0e6bdd8a15bd681
#   Reference: https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0/apis/docker_registry_api.html
#   
#   usage ./12-3-remove-registry-image.sh filterString
#   
#   ./12-3-remove-registry-image.sh nameSpace/textString
#
# ----------------------------------------------------------------------------------------------------\\

set -e

# Get the variables
source 00-variables.sh
clear

echo -e "${tools}   Welcome to the delete registry script for an IBM Cloud Private Cluster v2 Docker Registry"

if [ "${OS}" == "rhel" ]; then
  sudo yum install epel-release -y
  sudo yum install jq -y
else
  sudo apt-get -qq install jq -y
fi

dockerRegistry='mycluster.icp'
dockerRegistryPort='8500'
user="$ICPUSER:$ICPPW"
imagesFilter="$1"

# get the list of images names that match the filter
CATALOG_TOKEN=$(curl --cacert $HOME/.kube/kubecfg.crt -u ${user} -ks "https://${dockerRegistry}:8443/image-manager/api/v1/auth/token?service=token-service&scope=registry:catalog:*" | jq -r '.token')
images=$(curl --cacert $HOME/.kube/kubecfg.crt -ks -H "Authorization: Bearer ${CATALOG_TOKEN}" "https://${dockerRegistry}:${dockerRegistryPort}/v2/_catalog" | jq -r '.repositories[]? | select(. | contains("'${imagesFilter}'")) ')

for image in $images ; do

    # get the list of tags for each image    
    TAG_TOKEN=$(curl --cacert $HOME/.kube/kubecfg.crt -u ${user} -ks "https://${dockerRegistry}:8443/image-manager/api/v1/auth/token?service=token-service&scope=repository:${image}:*" | jq -r '.token') 
    tags=$(curl --cacert $HOME/.kube/kubecfg.crt -ks -H "Authorization: Bearer ${TAG_TOKEN}" "https://${dockerRegistry}:${dockerRegistryPort}/v2/${image}/tags/list" | jq -r .tags[]?)

    for tag in $tags ; do

        echo "${image}:${tag}"
        # get the digest of the image:tag
    	digest=$(curl -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -v --cacert $HOME/.kube/kubecfg.crt -ks -H "Authorization: Bearer ${TAG_TOKEN}" "https://${dockerRegistry}:${dockerRegistryPort}/v2/${image}/manifests/${tag}" 2>&1  | grep -e "Docker-Content-Digest:*" | awk '{ sub(/\r/,"",$3) ; print $3 }')
        if [ -z $digest ] ; then
            echo "${image}:${tag} not found"
        else
            echo -e "${litter}  Deleting ${image}:${tag}:${digest}"
            curl -XDELETE -w "[%{http_code}]\n" --cacert $HOME/.kube/kubecfg.crt -ks -H "Authorization: Bearer ${TAG_TOKEN}" "https://${dockerRegistry}:${dockerRegistryPort}/v2/${image}/manifests/${digest}"
        fi
        echo "...."
    done
done

if [ -n "${images}" ]; then
  echo -e "${fail}   No images matching provided filterString (${imagesFilter}) found"
else
  echo -e "${beers}   Congrats!  All images matching chosen filterString (${imagesFilter}) have been deleted"
fi
