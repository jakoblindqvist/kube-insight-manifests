# kube-learn-manifests

## Install
* Download install script `curl https://raw.githubusercontent.com/jakoblindqvist/kube-insight-manifests/master/toDoOnFirstStart.sh > install.sh`
* Change permission `chmod +x install.sh`
* Run install script `./install.sh` (if istio should be included `./install.sh istio`)
* Done! Check by running `kubectl get pod -n metrics`

Alternatively just run

* `curl https://raw.githubusercontent.com/jakoblindqvist/kube-insight-manifests/master/toDoOnFirstStart.sh | bash -`
* With istio `curl https://raw.githubusercontent.com/jakoblindqvist/kube-insight-manifests/master/toDoOnFirstStart.sh | bash /dev/stdin istio`