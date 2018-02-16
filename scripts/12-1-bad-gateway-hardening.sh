#!/bin/bash
# ----------------------------------------------------------------------------------------------------\\
# Description:
#   A basic hardening script to improve resilience of cluster reboots for RHEL 7.4 or Ubuntu 16.04
# ----------------------------------------------------------------------------------------------------\\
# Get the variables
source 00-variables.sh
set -e

READINESS_THRESHOLD=20
READINESS_PERIOD_SECONDS=60
INITIAL_DELAY_SECONDS=180

echo "To help improve the reliability of ICP across system restart, two strategies are employed:"
echo "     1.  Update the calico default component versions to help improve its instantiation startup time"
echo "     2.  Update the ICP-DS pod to be more patient with its readiness probe (important in slow network envs)"

echo ""
echo "Employing Strategy 1:  Updating calico components for node, cni and kube-controllers to align with the Calico 2.6.7 release"
echo "    Please refer to https://docs.projectcalico.org/v2.6/releases/ for more details"

# For goodness, let's make sure that the RollingUpdate strategy is in place.
STRATEGY=$(kubectl get ds/calico-node-amd64 -n kube-system -o go-template='{{.spec.updateStrategy.type}}{{"\n"}}')

if [ "$STRATEGY" = "RollingUpdate" ]; then
  # Do the patching of the daemonset resources
  # Reference:  https://docs.projectcalico.org/v2.6/releases/
  echo "    Updating calico-node-amd64 daemonset image versions ..."
  kubectl set image ds/calico-node-amd64 -n kube-system calico-node-amd64=calico/node:v2.6.7 install-cni=calico/cni:v1.11.2
  echo "    Updating calico-policy-controller deployment image version ..."
  kubectl set image deploy/calico-policy-controller -n kube-system calico-policy-controller=calico/kube-controllers:v1.0.3
  echo "Sweet! Your calico components have been upgraded"
else
  # Err out and state that the deploy appears to be older than 1.6 and cannot be ICP
  echo "Hmmmmmmm.    Your rolling update strategy does not appear to be set to RollingUpdate for the calico daemonsets and deployment."
  echo "Please inspect your rolling update strategy and try again"
  echo "Executing kubectl get ds/calico-node-amd64 -n kube-system -o go-template='{{.spec.updateStrategy.type}}{{"\n"}}'"
  echo ""
  kubectl get ds/calico-node-amd64 -n kube-system -o go-template='{{.spec.updateStrategy.type}}{{"\n"}}'
  echo ""
  exit 1
fi

echo "Restarting cluster ..."
#./12-0-reset-cluster.sh
./10-waiter.sh "pods" "kube-system" "0/1"

echo ""
echo "Employing Strategy 2:  Reapplying icp-ds template with updated readiness probe thresholds set to ${READINESS_THRESHOLD}"

CURRENTFAILURESETTING=$(kubectl get statefulset icp-ds -n kube-system -o jsonpath='{.spec.template.spec.containers[*].readinessProbe.failureThreshold}')
CURRENTPERIODSETTING=$(kubectl get statefulset icp-ds -n kube-system -o jsonpath='{.spec.template.spec.containers[*].readinessProbe.periodSeconds}')
CURRENTDELAYSETTING=$(kubectl get statefulset icp-ds -n kube-system -o jsonpath='{.spec.template.spec.containers[*].readinessProbe.initialDelaySeconds}')
echo "Your current ICP-DS readinessProbe failureThreshold is set to "${CURRENTFAILURESETTING}""
echo "Your current ICP-DS readinessProbe periodSeconds is set to "${CURRENTPERIODSETTING}""
echo "Your current ICP-DS readinessProbe initialDelaySeconds is set to "${CURRENTDELAYSETTING}""

if ([ "${CURRENTFAILURESETTING}" != "${READINESS_THRESHOLD}" ] || [ "${CURRENTPERIODSETTING}" != "${READINESS_PERIOD_SECONDS}" ] || [ "${CURRENTDELAYSETTING}" != "${INITIAL_DELAY_SECONDS}" ]); then
  kubectl patch statefulset/icp-ds -n kube-system -p '{"spec":{"template":{"spec":{"containers":[{"name":"icp-ds", "readinessProbe":{"failureThreshold":'"${READINESS_THRESHOLD}"',"periodSeconds":'"${READINESS_PERIOD_SECONDS}"',"initialDelaySeconds":'"${INITIAL_DELAY_SECONDS}"'}}]}}}}'
  ./10-waiter.sh "statefulset" "kube-system" "0/1"
else
  echo "Your ICP=DS statefulset has already been patched"
  exit 0
fi

echo ""
echo "Executing kubectl get statefulset icp-ds -n kube-system -o jsonpath='{.spec.template.spec.containers[*].readinessProbe.failureThreshold}'"
echo "Congrats! Your statefulset failureThreshold setting is now updated to $(kubectl get statefulset icp-ds -n kube-system -o jsonpath='{.spec.template.spec.containers[*].readinessProbe.failureThreshold}')"

echo ""
echo "Executing kubectl get statefulset icp-ds -n kube-system -o jsonpath='{.spec.template.spec.containers[*].readinessProbe.periodSeconds}'"
echo "Congrats!  Your statefulset periodSeconds setting is now update to $(kubectl get statefulset icp-ds -n kube-system -o jsonpath='{.spec.template.spec.containers[*].readinessProbe.periodSeconds}')"
echo ""
echo "Executing kubectl get statefulset icp-ds -n kube-system -o jsonpath='{.spec.template.spec.containers[*].readinessProbe.initialDelaySeconds}'"
echo "Congrats! Your statefulset failureThreshold setting is now updated to $(kubectl get statefulset icp-ds -n kube-system -o jsonpath='{.spec.template.spec.containers[*].readinessProbe.initialDelaySeconds}')"
echo ""

echo "Sweet! Give your system a few minutes to settle into its new surrounding.  After all pods are running, your cluster should be in a more resilient position for machine restarts"
echo "PROTIP:  the icp-ds stateful set is a critical component.  The pod that it manages can get stuck in a perpetual terminating state.  To help resolve, execute kubectl delete po/icp-ds-0 --grace-period=0 --force"
./10-waiter.sh "pods" "kube-system" "0/1"
echo "Happy Kubing!"
