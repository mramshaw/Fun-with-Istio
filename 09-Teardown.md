# Tear Down Istio

## Remove sidecar injection

Delete sidecar injection as follows:

    $ kubectl delete -f install/kubernetes/istio-sidecar-injector-with-ca-bundle.yaml


## Remove sidecar injection certificates

Delete sidecar injection certificates as follows:

    $ kubectl -n istio-system delete secret sidecar-injector-certs


## Delete CSR

Delete the CSR as follows:

    $ kubectl delete csr istio-sidecar-injector.istio-system


## Remove Injection label

Remove the `default` namespace injection label as follows:

    $ kubectl label namespace default istio-injection-


## Stop Istio

Tear down Istio as follows:

    $ kubectl delete -f install/kubernetes/istio.yaml


## Stop minikube

As usual:

    $ minikube stop
