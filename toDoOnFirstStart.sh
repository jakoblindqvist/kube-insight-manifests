#!/bin/bash

# Get and install helm
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash

# Make sure metrics namespace is initialized
kubectl create ns metrics
set -e

if [[ $1 == "istio" ]]; then
  # curl -L https://git.io/getLatestIstio | ISTIO_VERSION=0.8.0 sh -
  extra="--set istioScrape.enabled=true"
  helm install istio-0.8.0/install/kubernetes/helm/istio --name istio --namespace metrics --set prometheus.enabled=false
fi

helm install agents --namespace metrics $extra

