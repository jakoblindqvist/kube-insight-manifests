#!/bin/bash

# Exit on any error
set -e

# Get and install helm
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash

# Get and generate istio deployment
curl -L https://git.io/getLatestIstio | ISTIO_VERSION=0.8.0 sh -
cd istio-0.8.0
helm template install/kubernetes/helm/istio --name istio --namespace metrics --set prometheus.enabled=false > ../istio.yaml

cd ..

# Get and generate kube-manifest-insight
git clone git@github.com:jakoblindqvist/kube-insight-manifests.git
cd kube-insight-manifests
# TODO fix to include this in a nicer way (helm)
cat ../prometheusConfMapAdd >> manifests/agents/metrics/templates/prometheus-configmap.yaml.j2
helm template <Fix this dir> --name kube-insight --namespace metrics > ../kube-insight.yaml

cd ..

# Deploy to kubernetes
kubectl create namespace metrics
kubectl apply -f istio.yaml
kubectl apply -f kube-insight-yaml
