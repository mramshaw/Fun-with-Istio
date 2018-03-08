# Fun with Istio

[Istio](https://istio.io/) is a very useful ___service mesh___.

Having played with the [0.1.6 release](https://github.com/mramshaw/istio-ingress-tutorial),
it seemed to be time to take another look at Istio and the current __0.6__ release.


## Istio pod spec requirements

Istio imposes some [requirements (and suggestions)](https://istio.io/docs/setup/kubernetes/sidecar-injection.html)
on pod specifications.

1. Required:

    Service ports must be named. The port names must be of the form
    <protocol>[-<suffix>] with http, http2, grpc, mongo, or redis as
    the <protocol> in order to take advantage of Istio’s routing features.
    For example, name: http2-foo or name: http are valid port names,
    but name: http2foo is not. If the port name does not begin with a
    recognized prefix or if the port is unnamed, traffic on the port
    will be treated as plain TCP traffic (unless the port explicitly
    uses Protocol: UDP to signify a UDP port).

2. Recommended:

    It is recommended that Pods deployed using the Kubernetes `Deployment`
    have an explicit `app` label in the Deployment specification. Each deployment
    specification should have a distinct `app` label with a value indicating
    something meaningful. The `app` label is used to add contextual information
    in distributed tracing.


## Istio requirements

1. Kubernetes 1.9 features mutating webhooks, which are enabled by default.

    [Manual proxy injection can be used for earlier versions of Kubernetes.]

2. Minikube version v0.25.0 or later is required for Kubernetes v1.9.


## Starting minikube

For this exercise I will use __minikube__ (a local Kubernetes). To save time,
I have created a script `minikube-istio.sh` to launch minikube with all of the
needed options (the most important are the last two: `MutatingAdmissionWebhook`
and `ValidatingAdmissionWebhook` - these enable __automatic sidecar injection__).

    $ ./minikube-istio.sh
    Starting local Kubernetes v1.9.0 cluster...
    Starting VM...
    Getting VM IP address...
    Moving files into cluster...
    Setting up certs...
    Connecting to cluster...
    Setting up kubeconfig...
    Starting cluster components...
    Kubectl is now configured to use the cluster.
    Loading cached images from config file.
    $

And verify we have the `admissionregistration.k8s.io/v1beta1` API enabled:

    $ kubectl api-versions | grep admissionregistration
    admissionregistration.k8s.io/v1alpha1
    admissionregistration.k8s.io/v1beta1
    $

[The second line indicates that we *do*.]


## Versions

* Istio 0.6
* Kubernetes v1.9.0
* minikube v0.25.0
* kubectl (Client: v1.8.6, Server: v1.9.0)
* Docker 17.12.1-ce (Client and Server)


## To Do

* [ ] Complete the Isto website tutorials


## Credits

Inspired by:

    http://blog.kubernetes.io/2017/05/managing-microservices-with-istio-service-mesh.html
