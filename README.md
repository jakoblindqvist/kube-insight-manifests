# kube-learn-manifests

Adds metrics capabilities to a existing cluster. Creates a new namespace, metrics, where all the pods lives.

## Install
* Download install script `curl https://raw.githubusercontent.com/jakoblindqvist/kube-insight-manifests/master/toDoOnFirstStart.sh > install.sh`
* Change permission `chmod +x install.sh`
* Run install script `./install.sh` (if istio should be included `./install.sh istio`)
* Done! Check by running `kubectl get pod -n metrics`

Alternatively just run

* `curl https://raw.githubusercontent.com/jakoblindqvist/kube-insight-manifests/master/toDoOnFirstStart.sh | bash -`
* With istio `curl https://raw.githubusercontent.com/jakoblindqvist/kube-insight-manifests/master/toDoOnFirstStart.sh | bash /dev/stdin istio`

## Configure for istio
To add a namespace to the istios autoinjection simply add the label `istio-injection` to the namespace via the command `kubectl label namespace <namepace to add> istio-injection=enabled`

Then restart all pods in that namespace to inject the sidecart and then you're configured.