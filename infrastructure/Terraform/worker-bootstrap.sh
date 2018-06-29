#!/bin/bash

set -e

scriptname=$(basename ${0})

token=3lcnt0.lk1vmu7e1y9l8pxq
master_apiserver_port=6443

function print_usage() {
    echo "${scriptname} [OPTIONS] <master-apiserver-ip>"
    echo ""
    echo "Options:"
    echo "--token=TOKEN      Token that node will use to register with"
    echo "                   the master. The token must be of the format:"
    echo "                   [a-z0-9]{6}.[a-z0-9]{16}. Default: ${token}"
    echo "--master-apiserver-port=PORT"
    echo "                   The port to connect to the API server on the"
    echo "                   master. Default: ${master_apiserver_port}"
}

function log() {
    echo "[${scriptname}]: ${1}"
}

function die() {
    log "error: ${1}"
    print_usage
    exit 1;
}

for arg in "${@}"; do
    case ${arg} in
	--token=*)
	    token=${arg/*=/}
	    ;;
	--master-apiserver-port=*)
	    master_apiserver_port=${arg/*=/}
	    ;;
	--*)
	    die "unrecognized option: ${arg}"
	    ;;
	*)
	    # assume remaining arguments are positional
	    break
	  ;;
    esac
    shift
done

if [ "${1}" = "" ]; then
    die "no master API server IP address given"
fi
master_apiserver_ip=${1}

log "master API server IP: ${master_apiserver_ip}"
log "master API server port: ${master_apiserver_port}"
log "cluster token: ${token}"

until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
    echo "sleeping"
    sleep 1
done
echo "Waking"

sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo tee /etc/apt/sources.list.d/kubernetes.list <<EOF
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update -y

#
# install version of docker that kubernetes officially supports.
# see https://kubernetes.io/docs/setup/independent/install-kubeadm/
#
sudo apt-get install -y docker.io
# kubernetes recommends running Docker with iptables and IP Masq disabled.
sudo mkdir -p /etc/systemd/system/docker.service.d/
sudo tee /etc/systemd/system/docker.service.d/10-docker-opts.conf <<EOF
Environment="DOCKER_OPTS=--iptables=false --ip-masq=false"
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker

#
# install kubernetes components
#
sudo apt-get install -y kubelet=1.10.4-* kubeadm=1.10.4-* kubectl=1.10.4-* kubernetes-cni

#
# install additional software
#
sudo apt-get install -y nfs-common jq

#
# install kubernetes worker and join cluster
#
sudo kubeadm join --token=${token} --discovery-token-unsafe-skip-ca-verification --ignore-preflight-errors=all ${master_apiserver_ip}:${master_apiserver_port}


echo "**************************************************"
echo "* $(hostname) done.                              *"
echo "**************************************************"
