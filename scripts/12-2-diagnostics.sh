#!/bin/bash
# ----------------------------------------------------------------------------------------------------\\
# Description:
#   A basic reset of the cluster and its workers for RHEL 7.4 or Ubuntu 16.04
# ----------------------------------------------------------------------------------------------------\\
# Get the variables
source 00-variables.sh

clear
echo ""
echo -e "${tools}${Cyan}  Gathering information about Cluster Nodes${no_color}"
NODEOVERVIEW=$(kubectl get nodes -o wide)
NODEHEALTH=$(echo "${NODEOVERVIEW}" | grep NotReady | wc -l)
ENTROPY_THRESHOLD=1200

echo ""
echo -e "${eyes}  Inspecting $(uname -n)..."
echo -e "${tools}  $(uname -a)"
if [ $(sysctl kernel.random.entropy_avail | awk '{print $3}') -lt "${ENTROPY_THRESHOLD}" ]; then
  echo -e "${crossbones}${Red}  ALERT! ${no_color} Your available entropy appears to be ${Red}low ${no_color}[e.g. < ${ENTROPY_THRESHOLD}]"
  sysctl kernel.random.entropy_avail
  echo ""
  # Good Ref:  http://blog.dustinkirkland.com/2014/02/random-seeds-in-ubuntu-1404-lts-cloud.html
  echo -e "${Cyan}PROTIP:  On systems with limited sources of real randomness we'd like to use some kind of PRNG to gather additional random bits."
  echo -e "         Why is this important: Applications which need security tend to use /dev/random as their entropy source to gain randomness."
  echo -e "         If /dev/random runs out of available entropy, it's unable to serve out more randomness and the application waiting for the "
  echo -e "         randomness ${Yellow}stalls${Cyan} until more random content is available."
  echo -e "         Potential Solution:  Consider HW RNG options.  As a fallback, an easy software RNG solution is HAVEGED"
  echo -e "         The idea behind HAVENGE is to use the effects of the hidden state associated with modern processor features"
  echo -e "         such as cache, branch prediction, pipelining, and instruction parallelism in conjunction with the processors"
  echo -e "         time stamp counter to generate random sequences."
  echo -e ""
  echo -e "         sudo apt-get install -y haveged OR the yum equivalent"
  echo -e "         sudo systemctl enable haveged.service && sudo systemctl start haveged.service"
  echo -e "         You may also test the system's Entropy via cat /dev/random | rngtest -c 1000${no_color}"
else
  echo -e "${Green}Congrats!  $(sysctl kernel.random.entropy_avail) looks good on $(uname -n)${no_color}"
fi
echo ""
echo "${NODEOVERVIEW}"
echo ""
if [ ${NODEHEALTH} -gt "0" ]; then
  echo -e "${crossbones}${Red}  ALERT! ${no_color}${NODEHEALTH} Node appears to be ${Red}unhealthy$no_color and marked as NotReady"
  echo "   $(echo "${NODEOVERVIEW}" | grep NotReady)" 
  echo ""
fi

echo ""
#echo "Running calico SDN diagnostics"
#sudo apt-get install ipset -y
#sudo calicoctl node diags

echo "Useful paths and files for inspection ..."
echo -e "${Cyan}  /etc/cfc/pods${no_color}"
echo -e "${Cyan}  /etc/cfc/pods/master.json${no_color}"
echo -e "${Cyan}  /etc/cfc/conf${no_color}"
echo -e "${Cyan}  /etc/cfc/conf/kube-controller-manager-config.yaml${no_color}"
echo ""
#Turn On if we need docker engine details
#docker info
#Turn On if we want all services and their status on the machine
#systemctl --no-pager list-unit-files --full
#Turn On if we most of the Linux paramters set on the machine
#sysctl -a

for ((i=0; i < $NUM_WORKERS; i++)); do
    echo -e ""
    echo -e "${eyes}   Inspecting ${WORKER_HOSTNAMES[i]} ..."
    echo -e ""
    echo -e "    $(ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} uname -a)"
    if [ $(ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sysctl kernel.random.entropy_avail | awk '{print $3}') -lt "${ENTROPY_THRESHOLD}" ]; then
  	echo -e "    ${crossbones}${Red}  ALERT! ${no_color} Your available entropy on ${WORKER_HOSTNAMES[i]} appears to be ${Red}low ${no_color}[e.g. < ${ENTROPY_THRESHOLD}]"
 	echo -e "    $(ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sysctl kernel.random.entropy_avail)"
        echo -e ""
        #  Good Ref:  http://blog.dustinkirkland.com/2014/02/random-seeds-in-ubuntu-1404-lts-cloud.html
  	echo -e "    ${Cyan}PROTIP:  On systems with limited sources of real randomness we'd like to use some kind of PRNG to gather additional random bits."
  	echo -e "             Why is this important: Applications which need security tend to use /dev/random as their entropy source to gain randomness."
        echo -e "         If /dev/random runs out of available entropy, it's unable to serve out more randomness and the application waiting for the "
        echo -e "         randomness ${Yellow}stalls${Cyan} until more random content is available."
  	echo -e "             Potential Solution:  Consider HW RNG options.  As a fallback, an easy software RNG solution is HAVEGED"
  	echo -e "             The idea behind HAVENGE is to use the effects of the hidden state associated with modern processor features"
  	echo -e "             such as cache, branch prediction, pipelining, and instruction parallelism in conjunction with the processors"
  	echo -e "             time stamp counter to generate random sequences."
  	echo -e ""
  	echo -e "             sudo apt-get install -y haveged OR the yum equivalent"
  	echo -e "             sudo systemctl enable haveged.service && sudo systemctl start haveged.service"
        echo -e "             You may also test the system's Entropy via cat /dev/random | rngtest -c 1000${no_color}"
    else
  	echo -e "    ${Green}Congrats!  $(ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sysctl kernel.random.entropy_avail) looks good on ${WORKER_HOSTNAMES[i]}${no_color}"
    fi
    #Turn On if we need docker engine details
    #echo -e "     $(ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} docker info)"
    #Turn On if we want all services and their status on the machine
    #echo -e "     $(ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} systemctl --no-pager list-unit-files --full)"
    #Turn On if we most of the Linux paramters set on the machine
    #echo -e "     $(ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sysctl -a)"
done

