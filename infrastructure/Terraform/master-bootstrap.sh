#!/bin/bash

set -e

scriptname=$(basename ${0})

token=3lcnt0.lk1vmu7e1y9l8pxq
k8s_version=1.10.4

function print_usage() {
    echo "${scriptname} [OPTIONS]"
    echo ""
    echo "Options:"
    echo "--token=TOKEN      Token that nodes will need use to register with"
    echo "                   the master. The token must be of the format:"
    echo "                   [a-z0-9]{6}.[a-z0-9]{16}. Default: ${token}"
    echo "--k8s-version=VER  Kubernetes version. Default: ${k8s_version}"
    echo "--apiserver-advertise-ip=IP"
    echo "                   The IP address that the API server should"
    echo "                   advertise (through which nodes can reach it)."
    echo "                   Typically the private IP address of the VM."
    echo "                   Default: the IP of the default network interface."
    echo "--extra-cert-sans=SAN1,SAN2,..."
    echo "                   Comma-separated list of additional hostnames or IP"
    echo "                   addresses that should be added to the Subject"
    echo "                   Alternate Name section for the cert that the API"
    echo "                   server will use. For example:"
    echo "                   kubeapi.mydomain.com,210.32.190.94."
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
	--extra-cert-sans=*)
	    extra_cert_sans=${arg/*=/}
	    extra_cert_sans=${extra_cert_sans/,/ }
	    ;;
	--apiserver-advertise-ip=*)
	    apiserver_advertise_ip=${arg/*=/}
	    ;;
	*)
	  die "unrecognized option: ${arg}"
	  ;;
    esac
    shift
done

log "version: ${k8s_version}"
log "cluster token: ${token}"
log "extra cert sans: ${extra_cert_sans}"
log "API server advertise IP: ${apiserver_advertise_ip}"


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
sudo usermod -a -G docker ubuntu


#
# install kubernetes components
#
sudo apt-get install -y kubelet=${k8s_version}-* kubeadm=${k8s_version}-* kubectl=${k8s_version}-* kubernetes-cni

#
# install additional software
#
sudo apt-get install -y nfs-common jq

#
# install kubernetes master
#

# create kubeadm config file
sudo mkdir -p /etc/kubeadm
sudo tee /etc/kubeadm/kubeadm-config.yaml > /dev/null <<EOF
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
kubernetesVersion: v${k8s_version}
token: ${token}
# Never expire token
tokenTTL: 0s
networking:
  podSubnet: 10.32.0.0/12
# Additional hostnames or IP addresses that should be added to the
# Subject Alternate Name section for the certificate that the API Server will
# use. For example, a public DNS name or a public IP.
apiServerCertSANs:
EOF
for extra_cert_san in ${extra_cert_sans}; do
    echo "- ${extra_cert_san}" | sudo tee -a /etc/kubeadm/kubeadm-config.yaml
done
if [ "${apiserver_advertise_ip}" != "" ]; then
    sudo tee -a /etc/kubeadm/kubeadm-config.yaml <<EOF
api:
  advertiseAddress: ${apiserver_advertise_ip}
EOF
fi

# bootstrap kubernetes
sudo kubeadm init --config=/etc/kubeadm/kubeadm-config.yaml
# install kubectl for root user
[ -d /root/.kube ] || sudo mkdir -p /root/.kube
sudo ln -s /etc/kubernetes/admin.conf /root/.kube/config


# install kubectl for ubuntu user
[ -d /home/ubuntu/.kube ] || sudo mkdir -p /home/ubuntu/.kube
sudo cp /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
sudo chown -R ubuntu:ubuntu /home/ubuntu/.kube/


# install a pod network
sysctl net.bridge.bridge-nf-call-iptables=1
export kubever=$(kubectl version | base64 | tr -d '\n')
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"


# allow all service accounts to act as administrators of the cluster
# See: https://kubernetes.io/docs/admin/authorization/rbac/
kubectl create clusterrolebinding permissive-binding \
  --clusterrole=cluster-admin \
  --user=admin \
  --user=kubelet \
  --group=system:serviceaccounts

echo "**************************************************************"
echo "* $(hostname) done.                                          *"
echo "**************************************************************"
