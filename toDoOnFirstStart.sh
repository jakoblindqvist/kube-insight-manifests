#!/bin/bash

# Get and install helm
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
helm init

# Make sure metrics namespace is initialized
kubectl create ns metrics
set -e

if [[ $1 == "istio" ]]; then
  curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.0.1 sh -
  extra="--set istioScrape.enabled=true"
  helm install istio-1.0.1/install/kubernetes/helm/istio --name istio --namespace metrics --set prometheus.enabled=false
fi

helm install agents --namespace metrics $extra

