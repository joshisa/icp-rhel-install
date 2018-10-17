#!/bin/bash
# ----------------------------------------------------------------------------------------------------\\
# Description:
#   A basic script port to change your cluster url on an ICP Cluster
#
#   Options:
#     None
#
#   Argument Formats Supported
#     - https://<Public IP>:8443
#     - https://<Public IP>:8443
#     - https://<Private IP>:8443
#     - https://<Private IP>:custom-port
#     - https://<host name>:8443
#     - https://<host name>:custom-port
#     - https://localhost:8443
#     - https://localhost:<custom port>
#     - https://<Regex host name>:8443
#     - https://<Regex IP>:8443
#     - https://<Regex host name>:<custom port>
#     - https://<Regex IP>:<custom port>
#     - https://<Regex host name>:<Regex port>
#     - https://<Regex IP>:<Regex Port>
#
#   Example:
#     ./12-8-modify-cluster-url.sh https://9.22.1.47:8443 https://localhost:8443
#
#   Reference:
#     https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.0/user_management/custom_url.html
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

JSON=$(kubectl get cm registration-json -n kube-system -o json | jq -j '.data."platform-oidc-registration.json"')

clear

# Display an error message if more than two arguments/flags exist
# Exit the shell script with a status of 1 using exit 1 command.
echo -e "${tools}   Welcome to the cluster url adjustment script for IBM Cloud Private"

if [ "${OS}" == "rhel" ]; then
  sudo yum install epel-release -y
  sudo yum install jq -y
else
  sudo apt-get -qq install jq -y
fi

JSON=$(echo -e "${JSON}" | jq --arg allow_regexp_redirects true '. + {allow_regexp_redirects: $allow_regexp_redirects}')

for var in "$@"
do
  JSON=$(echo -e "${JSON}" | jq '.redirect_uris[.redirect_uris | length] |= . + "'${var}'/auth/liberty/callback"' | jq '.trusted_uri_prefixes[.trusted_uri_prefixes | length] |= . + "'${var}'"' | jq '.post_logout_redirect_uris[.post_logout_redirect_uris  | length] |= . + "'${var}'/console/logout"')
done

OAUTH2_CLIENT_REGISTRATION_SECRET=$(kubectl -n kube-system get secret platform-oidc-credentials -o yaml | grep OAUTH2_CLIENT_REGISTRATION_SECRET | awk '{ print $2}' | base64 --decode)
WLP_CLIENT_ID=$(kubectl -n kube-system get secret platform-oidc-credentials -o yaml | grep WLP_CLIENT_ID | awk '{print $2}' | base64 --decode)
FIP=$(kubectl get nodes | grep master | awk '{print $1}')

curl -kvv -X PUT -u oauthadmin:$OAUTH2_CLIENT_REGISTRATION_SECRET -H "Content-Type: application/json" -d "${JSON}" https://$FIP:9443/oidc/endpoint/OP/registration/$WLP_CLIENT_ID
