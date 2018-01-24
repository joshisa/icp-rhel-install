#!/usr/bin/env bash

set -e
set -u

#if [ -z ${SS_POLL_INTERVAL} ]; then
#  SS_POLL_INTERVAL=10;
#fi # Number of seconds until script polls spark cluster again.

#if [ -z ${SS_DEBUG} ]; then
#  SS_DEBUG=false;
#fi # Detailed debugging

# -- Set working environment variables ----------------------------------------

#if [ "${SS_DEBUG}" = "true" ]
#then
#  set -x
#fi

jobFinished=false
jobFailed=false
try=1
while [[ "${jobFinished}" == false ]]
do
    echo "\nPolling job status.  Poll #${try}.\n"
    resultStatus=$(kubectl get pods -n kube-system | grep "0/1" | wc -l)
    ((try++))
    driverStatus="`echo ${resultStatus} `"
    echo "${driverStatus} ICP system pod deployments are still unready"
    case ${driverStatus} in
        FINISHED)
            echo "All ICP system pods are now ready."
            jobFinished=true
            ;;
        RUNNING|SUBMITTED)
            echo "Next poll in 10 seconds.\n"
            sleep 10
            jobFinished=false
            ;;
        *)
            IS_JOB_ERROR=true
            echo "${resultStatus}\n"
            echo "===============================================================================\n\n"
            jobFinished=true
            jobFailed=true
            ;;
    esac
done
