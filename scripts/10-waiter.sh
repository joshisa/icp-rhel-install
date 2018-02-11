#!/usr/bin/env bash

set -e
set -u

K8S_POLL_INTERVAL=7 # Number of seconds until script polls cluster again.
K8S_THRESHOLD=80
K8S_DEBUG=false; # Detailed debugging
K8S_RESOURCE_TYPE=$1
K8S_NAMESPACE=$2
TEXT=$3

# -- Set working environment variables ----------------------------------------

if [ "${K8S_DEBUG}" = "true" ]
then
  set -x
fi

jobFinished=false
jobFailed=false
try=1

while [[ "${jobFinished}" == false ]]
do
    echo "Polling ICP pod deployments within namespace ${K8S_NAMESPACE}.  Poll #${try}."
    resultStatus=$(kubectl get $K8S_RESOURCE_TYPE -n ${K8S_NAMESPACE}| grep ${TEXT} | wc -l)
    ((try++))
    if [ "$resultStatus" -eq "0" ]; then
      driverStatus="FINISHED"
    else
      if [ "${try}" -ge "${K8S_THRESHOLD}" ]; then
        driverStatus="ERROR";
      else
        driverStatus="UNREADY"
      fi 
    fi
    case ${driverStatus} in
        FINISHED)
            echo "All ICP ${K8S_RESOURCE_TYPE} within namespace ${K8S_NAMESPACE} are now ready."
            jobFinished=true
            ;;
        UNREADY)
            echo "${resultStatus} ICP ${K8S_RESOURCE_TYPE} within namespace ${K8S_NAMESPACE} are still UNREADY"
            echo "Next poll in ${K8S_POLL_INTERVAL} seconds."
            sleep ${K8S_POLL_INTERVAL}
            jobFinished=false
            ;;
        *)
            IS_JOB_ERROR=true
            echo "Hmmmm .... something is really wrong with your K8S cluster"
            echo "${resultStatus} ICP ${K8S_RESOURCE_TYPE} within namespace ${K8S_NAMESPACE} are still UNREADY"
            jobFinished=true
            jobFailed=true
            ;;
    esac
done
