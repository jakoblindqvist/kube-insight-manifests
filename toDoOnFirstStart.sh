#!/bin/bash

# Exit on any error
set -e

# Get and install helm
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash

if [[ $1 == "istio" ]]; then
  # Get and generate istio deployment
  curl -L https://git.io/getLatestIstio | ISTIO_VERSION=0.8.0 sh -
  cd istio-0.8.0
  helm template install/kubernetes/helm/istio --name istio --namespace metrics --set prometheus.enabled=false > ../istio.yaml

  cd ..
fi

# Get and generate kube-manifest-insight
git clone https://github.com/jakoblindqvist/kube-insight-manifests.git
cd kube-insight-manifests

baseCommand="helm template agents --namespace metrics"
if [[ $1 == "istio" ]]; then
  extra="--set istioScrape.enabled=true"
fi

$baseCommand $extra > ../kube-learn-agent.yaml
helm template servers --namespace metrics > ../kube-learn-server.yaml

cd ..

# Deploy to kubernetes
kubectl create namespace metrics
if [[ $1 == "istio" ]]; then
  kubectl apply -f istio.yaml
fi
kubectl apply -f kube-learn-server.yaml
kubectl apply -f kube-learn-agent.yaml
