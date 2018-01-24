#!/usr/bin/env bash

set -e
set -u

K8S_POLL_INTERVAL=7 # Number of seconds until script polls cluster again.
K8S_THRESHOLD=20
K8S_DEBUG=false; # Detailed debugging

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
    echo "Polling ICP system pod deployments.  Poll #${try}."
    resultStatus=$(kubectl get pods -n kube-system | grep "0/1" | wc -l)
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
            echo "All ICP system pods are now ready."
            jobFinished=true
            ;;
        UNREADY)
            echo "${resultStatus} ICP system pod deployments are still UNREADY"
            echo "Next poll in ${K8S_POLL_INTERVAL} seconds."
            sleep ${K8S_POLL_INTERVAL}
            jobFinished=false
            ;;
        *)
            IS_JOB_ERROR=true
            echo "Hmmmm .... something is really wrong with your K8S cluster"
            echo "${resultStatus} ICP system pod deployments are still UNREADY"
            jobFinished=true
            jobFailed=true
            ;;
    esac
done
