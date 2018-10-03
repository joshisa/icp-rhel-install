#!/bin/bash
# ----------------------------------------------------------------------------------------------------\\
# Description:
#   A basic script port to manage registry images on an ICP Cluster
#   Fork of https://gist.github.com/mohamed-el-habib/26d26dddaf3dcefcc0e6bdd8a15bd681
#   Reference: https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0/apis/docker_registry_api.html
#
#   usage ./12-7-image-registry-management.sh filterString [--delete, -d] [--no-prompt]
#
#   Options:
#       --delete, -d   (Optional) Flag to delete matched image names
#       --no-prompt    (Optional) Flag to suppress delete confirmation.
#                                 Only useful in conjunction with delete flag
#
#   Example:   ./12-7-image-registry-management.sh nameSpace/textString
#    Result:   Will list all images matching nameSpace/textString filter
#
#   Example:   ./12-7-image-registry-management.sh :v3.1.3
#    Result:   Will list all images matching tag filter (v3.1.3)
#
#   Example:   ./12-7-image-registry-management.sh nameSpace/textString:v3.1.3
#    Result:   Will list all images matching nameSpace/textString filter AND tag filter (v3.1.3)
#
#   Example:   ./12-7-image-registry-management.sh nameSpace/textString --delete
#    Result:   Will list AND delete all images matching nameSpace/textString filter after prompt
#
#   Example:   ./12-7-image-registry-management.sh nameSpace/textString --delete --no-prompt
#    Result:   Will list AND delete all images matching nameSpace/textString filter with no prompt
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

#IBM Cloud Private Cluster Administrator Credentials
export ICPUSER=admin
export ICPPW=admin
export HAS_DELETE=false
export NO_PROMPT=false
export ONE_ARG=false

imageCount=0

# Clear Screen
clear

# Display an error message if more than two arguments/flags exist
# Exit the shell script with a status of 1 using exit 1 command.
[ $# -gt 2 ] && { echo -e "${crossbones}   Error.  Too many arguments.\n    Usage: $0 [text] [--delete, -d] [--no-prompt]"; exit 1; }

[ ! -f $HOME/.kube/kubecfg.crt ] && { echo -e "${crossbones}   Error.  Missing $HOME/.kube/kubecfg.crt .  This file can be found on the Master Node at /etc/cfc/conf/kubecfg.crt"; exit 1; }

echo -e "${tools}   Welcome to the image management registry script for an IBM Cloud Private Cluster v2 Docker Registry"

if [ "${OS}" == "rhel" ]; then
  sudo yum install epel-release -y
  sudo yum install jq -y
else
  sudo apt-get -qq install jq -y
fi

dockerRegistry='mycluster.icp'
dockerRegistryPort='8500'
user="$ICPUSER:$ICPPW"
imagesFilter="default/"
tagsFilter="."

# Detected only one argument.  Helps with message display.
if [ $# -eq 1 ]; then
    ONE_ARG=true;
fi

# We're using defaults
[ $# -eq 0 ] && { echo -e "${harpoons}   Scanning IBM Cloud Private Image Registry for image names containing ${imagesFilter}"; }

# Looping through arguments.  Currently support raw text filter and --delete flag
while [ ! $# -eq 0 ]
do
	case "$1" in
		--delete | -d)
		        HAS_DELETE=true
			[ ${ONE_ARG} = true ] && { echo -e "${harpoons}   Scanning IBM Cloud Private Image Registry for image names containing ${imagesFilter}"; }
			;;
		--no-prompt)
			NO_PROMPT=true
			;;
	        *)
			if ! [[ "$1" =~ [^a-zA-Z0-9\/\\\.\:\-] ]]; then
                          #echo "VALID"
			  echo -e "${harpoons}   Scanning IBM Cloud Private Image Registry for image names containing ${1}"
                          case $1 in
   			    (*:*) imagesFilter="${1%:*}" tagsFilter="${1##*:}";;
   			    (*)   imagesFilter="$1";;
			  esac
                        else
	       		  echo "An invalid filter string (${1}) was provided. Only alphanumerics [0-9] [a-zA-Z] are permitted"
			  exit;
                        fi
			;;
	esac
	shift
done

# Erring on the side of caution, asking if user really wants to delete
if [ ${HAS_DELETE} = true ] && [ ${NO_PROMPT} = false ]; then
    echo -e "${crossbones}   Deletion mode detected ..."
    read -p "Are you sure that you want to delete image names matching \"${imagesFilter}\" ? [YyNn] " -n 1 -r
    echo -e "\n"   # (optional) move to a new line
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
       [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
    fi
fi

# get the list of images names that match the filter
CATALOG_TOKEN=$(curl --cacert $HOME/.kube/kubecfg.crt -u ${user} -ks "https://${dockerRegistry}:8443/image-manager/api/v1/auth/token?service=token-service&scope=registry:catalog:*" | jq -r '.token')
images=$(curl --cacert $HOME/.kube/kubecfg.crt -ks -H "Authorization: Bearer ${CATALOG_TOKEN}" "https://${dockerRegistry}:${dockerRegistryPort}/v2/_catalog" | jq -r '.repositories[]? | select(. | contains("'${imagesFilter}'")) ')

for image in $images ; do

    # Increment image counter
    ((imageCount++))

    # get the list of tags for each image
    TAG_TOKEN=$(curl --cacert $HOME/.kube/kubecfg.crt -u ${user} -ks "https://${dockerRegistry}:8443/image-manager/api/v1/auth/token?service=token-service&scope=repository:${image}:*" | jq -r '.token')
    tags=$(curl --cacert $HOME/.kube/kubecfg.crt -ks -H "Authorization: Bearer ${TAG_TOKEN}" "https://${dockerRegistry}:${dockerRegistryPort}/v2/${image}/tags/list" | jq -r '.tags[]? | select(. | contains("'${tagsFilter}'")) ')

    for tag in $tags ; do

        # echo "${image}:${tag}"
        # get the digest of the image:tag
	# docker-content-digest
        digest=$(curl -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -v --cacert $HOME/.kube/kubecfg.crt -ks -H "Authorization: Bearer ${TAG_TOKEN}" "https://${dockerRegistry}:${dockerRegistryPort}/v2/${image}/manifests/${tag}" 2>&1  | grep -i -e "docker-content-digest:*" | awk '{ sub(/\r/,"",$3) ; print $3 }')
	if [ -z $digest ] ; then
            echo "${image}:${tag} not found"
	else
            if [ "${HAS_DELETE}" = true ]; then
                echo -e "${litter}  Deleting ${image}:${tag}:${digest}"
                curl -XDELETE -w "[%{http_code}]\n" --cacert $HOME/.kube/kubecfg.crt -ks -H "Authorization: Bearer ${TAG_TOKEN}" "https://${dockerRegistry}:${dockerRegistryPort}/v2/${image}/manifests/${digest}"
	    else
	        echo "${image}:${tag}"
	    fi
	    echo "...."
        fi
    done
done

if [ -z "${images}" ]; then
    echo -e "${fail}   No images matching provided filterString (${imagesFilter}) found"
else
    if [ "${HAS_DELETE}" = true ]; then
        echo -e "${beers}   Congrats!  All ${imageCount} images matching chosen filterString (${imagesFilter}:${tagsFilter}) have been deleted"
    else
        echo -e "${beers}   Congrats!  All ${imageCount} images matching chosen filterString (${imagesFilter}:${tagsFilter}) have been retrieved"
    fi
fi
