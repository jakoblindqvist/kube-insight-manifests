# kube-learn-manifests

Adds metrics capabilities to a existing cluster. Creates a new namespace, metrics, where all the pods lives.

## Install
1. Download install script `curl https://raw.githubusercontent.com/jakoblindqvist/kube-insight-manifests/master/toDoOnFirstStart.sh > install.sh`
2. Change permission `chmod +x install.sh`
3. Run install script `./install.sh` (if istio should be included `./install.sh istio`)
4. Done! Check by running `kubectl get pod -n metrics`

Alternatively just run

* `curl https://raw.githubusercontent.com/jakoblindqvist/kube-insight-manifests/master/toDoOnFirstStart.sh | bash -`
* With istio `curl https://raw.githubusercontent.com/jakoblindqvist/kube-insight-manifests/master/toDoOnFirstStart.sh | bash /dev/stdin istio`

## Configure for istio
To add a namespace to the istios autoinjection add the label `istio-injection` to the namespace via the command `kubectl label namespace <namepace to add> istio-injection=enabled`

Then restart all pods in that namespace to inject the sidecart and then the configuration is complete.

## Metrics

Several systems are used for monitoring and each of these produce a set of metrics.
The metrics scraped by prometheus include:

* [Istio](https://istio.io/docs/reference/config/policy-and-telemetry/metrics/)
* [Node exporter](https://github.com/prometheus/node_exporter)
* [cAdvisor](https://github.com/google/cadvisor/blob/master/docs/storage/prometheus.md)
* [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics/tree/master/Documentation)
