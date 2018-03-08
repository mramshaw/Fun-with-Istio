# Fun with Istio

[Istio](https://istio.io/) is a very useful ___service mesh___.

Having played with the [0.1.6 release](https://github.com/mramshaw/istio-ingress-tutorial),
it seemed to be time to take another look at Istio and the current __0.6__ release.


## Istio pod spec requirements

Istio imposes some [requirements (and suggestions)](https://istio.io/docs/setup/kubernetes/sidecar-injection.html)
on pod specifications.

1. Required:

    Service ports must be named. The port names must be of the form
    __\<protocol\>[-\<suffix\>]__ with ___http___, ___http2___, ___grpc___,
    ___mongo___, or ___redis___ as the __\<protocol\>__ in order to take
    advantage of Istio’s routing features. For example, __name: http2-foo__
    or __name: http__ are valid port names, but __name: http2foo__ is not.
    If the port name does not begin with a recognized prefix or if the port
    is unnamed, traffic on the port will be treated as plain TCP traffic
    (unless the port explicitly uses __Protocol: UDP__ to signify a UDP port).

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

There are various options for installing Istio. For this exercise I will use
__minikube__ (a local Kubernetes). To save time, I have created a script
`minikube-istio.sh` to launch minikube with all of the needed options (the
most important are: `MutatingAdmissionWebhook` and `ValidatingAdmissionWebhook`
 - which enable [automatic sidecar injection](#automatic-sidecar-injection)).

Note that the __order__ of the options is important.

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

Verify we have the `admissionregistration.k8s.io/v1beta1` API enabled:

    $ kubectl api-versions | grep admissionregistration
    admissionregistration.k8s.io/v1alpha1
    admissionregistration.k8s.io/v1beta1
    $

[The second line indicates that we *do*.]


## Istio

1. Download [Istio](https://github.com/istio/istio/releases) and uncompress it into this directory.

2. [Optional] The compressed istio can now be deleted.

3. Change directory into the Istio directory.

4. Launch Istio as follows:

    $ kubectl apply -f install/kubernetes/istio.yaml

5. Monitor what's happening with the following command:

    $ kubectl get all --namespace=istio-system

6. Generate a CSR as follows:

    ./install/kubernetes/webhook-create-signed-cert.sh \
        --service istio-sidecar-injector \
        --namespace istio-system \
        --secret sidecar-injector-certs

7. Install the Sidecar Injector ConfigMap as follows:

    $ kubectl apply -f install/kubernetes/istio-sidecar-injector-configmap-release.yaml

    [This is the `release` version - note that there is a `debug` version as well.]

8. Install the caBundle (Certificate Authourity bundle?) as follows:

    $ cat install/kubernetes/istio-sidecar-injector.yaml | \
         ./install/kubernetes/webhook-patch-ca-bundle.sh > \
         install/kubernetes/istio-sidecar-injector-with-ca-bundle.yaml

9. Install the webhook:

    $ kubectl apply -f install/kubernetes/istio-sidecar-injector-with-ca-bundle.yaml

    Verify it is running:

    $ kubectl get deployment --selector istio=sidecar-injector --namespace=istio-system


## Automatic sidecar injection

Once everything is set up, it should be possible to annotate containers for
sidecar (envoy) injection as follows:

    sidecar.istio.io/inject: "true"

[Can be applied via YAML/JSON or via `kubectl`.]

Verify `default` namespace has been annotated as follows:

    $ kubectl get namespace -L istio-injection
    NAME           STATUS    AGE       ISTIO-INJECTION
    default        Active    21d       enabled
    istio-system   Active    15m       
    kube-public    Active    21d       
    kube-system    Active    21d       
    $

    $ kubectl get pod
    NAME                            READY     STATUS        RESTARTS   AGE
    sleep-776b7bcdcd-dpnlq          1/1       Terminating   0          8m
    sleep-776b7bcdcd-p2gts          0/2       Init:0/1      0          3s
    $


## Addons

Install any desired addons (Grafana, Prometheus, Zipkin) as follows:

    $ kubectl apply -f install/kubernetes/addons/grafana.yaml

Extract the needed network details as follows:

    $ export GRAFANA_URL=$(kubectl get po -l app=grafana -n istio-system -o jsonpath={.items[0].status.hostIP}):$(kubectl get svc grafana -n istio-system -o jsonpath={.spec.ports[0].nodePort})

Can then open a dashboard as follows:

    http://$GRAFANA_URL/dashboard/db/istio-dashboard

Or (using `minikube`):

    $ minikube service --url svc/grafana

Can port-forward as follows:

    $ $ kubectl port-forward grafana-89f97d9c-qvqrp -n istio-system 3000:3000


## Remove sidecar injection

Delete sidecar injection as follows:

    $ kubectl delete -f install/kubernetes/istio-sidecar-injector-with-ca-bundle.yaml


## Stopping Istio

Tear down Istio as follows:

    $ kubectl delete -f install/kubernetes/istio.yaml


## Stopping minikube

As usual:

    $ minikube stop


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
