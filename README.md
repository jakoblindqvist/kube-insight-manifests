# kube-insight-manifests

`kube-insight` is a Kubernetes observability stack, intended to integrate best-of-breed open-source cluster monitoring products with the intent of creating a comprehensive observability solution to help administrators track overall cluster and micro-service health, and to better understand the systems dynamics.

This repository contains the Kubernetes manifests neccesary to deploy the `kube-insight` stack. As such, it merely references included docker images. The actual code of the software components of the stack are kept in separate repositories.

`kube-insight` is intended to provide the following key functionalities:

* *topology-awareness:* automatically discover the service dependency graph by detecting the communication flow between containers.
* *metrics collection:* collect container metrics for all deployed services.
* *log collection:* collect container logs for troubleshooting
* *event collection:* collect Kubernetes events to form a system change history to, for example, be able to determine what changes introduced a performance degradation.
* *visualization:* provide a single UI for visualizing the system state in a topology-centric manner, allowing drill-down to watch details (metrics, logs, events) pertaining to a certain deployment/pod/container.
* *time-travel:* by continusously saving state (topology, metrics, logs, events) in a backing Cassandra cluster, the system state is tracked over time to produce a system audit trail.

We believe that `kube-insight` can ease the life of Kubernetes cluster operators by providing contextualized insight into the system. Todays microservice-based architectures involve a lot of moving parts with complex inter-dependencies. The combination of topology-awareness and tracking per-container data such as logs and metrics should simplify the task of root-cause-analysis, by quickly allowing the operator to zoom in on the relevant services and then being able to drill down to troubleshoot individual pods (for example by looking at their metrics, logs).

This project is based on modern, cloud-native components, and adds some glue-code where necessary to integrate third-party software. For more details refer to the [architecture](#architecture) section below.

## Project status

This project is very much a work in progress. Additional manifests need to be added as components are added to the stack.

## Architecture

The system is divided into two parts. Helm charts intended to be deployed onto the *monitored cluster* ("agents") and a docker compose file that starts a database so the agents can send the data *(metrics)* to a persistent store ("store").

**NOTE:** The agents and the store can run on the same system but it's recommended to run them on different systems so the metrics is available even if the cluster goes down.

### Agents

Several systems are used for monitoring and each of these produce a set of metrics.
The metrics scraped by prometheus include:

* [Istio](https://istio.io/docs/reference/config/policy-and-telemetry/metrics/)
* [Node exporter](https://github.com/prometheus/node_exporter)
* [cAdvisor](https://github.com/google/cadvisor/blob/master/docs/storage/prometheus.md)
* [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics/tree/master/Documentation)

## Install
1. Download install script `curl https://raw.githubusercontent.com/jakoblindqvist/kube-insight-manifests/master/toDoOnFirstStart.sh > install.sh`
2. Change permission `chmod +x install.sh`
3. Run install script `./install.sh` (if istio should be included `./install.sh istio`)
4. Done! Check by running `kubectl get pod -n metrics`

Alternatively just run

* `curl https://raw.githubusercontent.com/jakoblindqvist/kube-insight-manifests/master/toDoOnFirstStart.sh | bash -`
* With istio `curl https://raw.githubusercontent.com/jakoblindqvist/kube-insight-manifests/master/toDoOnFirstStart.sh | bash /dev/stdin istio`

## Configure with istio
To add a namespace to the istios autoinjection add the label `istio-injection` to the namespace via the command `kubectl label namespace <namepace to add> istio-injection=enabled`

Then restart all pods in that namespace to inject the sidecart and then the configuration is complete.
