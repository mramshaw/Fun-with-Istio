# Fun with Istio

[Istio](https://istio.io/) is a very useful ___service mesh___.
As such, it handles service-to-service communications.

It comes with addons, such as [Prometheus](https://prometheus.io/), [Grafana](https://grafana.com/)
and [Zipkin](https://zipkin.io/).

Having played with the [0.1.6 release](https://github.com/mramshaw/istio-ingress-tutorial),
it seemed to be time to take another look at Istio and the current __0.6__ release.

The plan of attack is as follows:

* [Final teardown](09-Teardown.md)
* [Software Versions](#versions)
* [Still To Do](#to-do)


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
`minikube-istio.sh` to launch minikube with the needed options (the most
important are `MutatingAdmissionWebhook` and `ValidatingAdmissionWebhook`
which enable [automatic sidecar injection](#automatic-sidecar-injection)).

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

    ```
    $ kubectl apply -f install/kubernetes/istio.yaml
    ```

5. Monitor what's happening with the following command:

    ```
    $ kubectl get all --namespace=istio-system
    ```

6. Generate a CSR as follows:

    ```
    ./install/kubernetes/webhook-create-signed-cert.sh \
        --service istio-sidecar-injector \
        --namespace istio-system \
        --secret sidecar-injector-certs
    ```

7. Install the Sidecar Injector ConfigMap as follows:

    ```
    $ kubectl apply -f install/kubernetes/istio-sidecar-injector-configmap-release.yaml
    ```

    [This is the `release` version - note that there is a `debug` version as well.]

8. Install the caBundle (Certificate Authourity bundle?) as follows:

    ```
    $ cat install/kubernetes/istio-sidecar-injector.yaml | \
         ./install/kubernetes/webhook-patch-ca-bundle.sh > \
         install/kubernetes/istio-sidecar-injector-with-ca-bundle.yaml
    ```

9. Install the webhook:

    ```
    $ kubectl apply -f install/kubernetes/istio-sidecar-injector-with-ca-bundle.yaml
    ```

    Verify it is running:

    ```
    $ kubectl get deployment --selector istio=sidecar-injector --namespace=istio-system
    ```


## Automatic sidecar injection

Once everything is set up, it should be possible to label namespaces and/or annotate deployments for sidecar injection.

While it would be possible to do this in a 'brute force' manner with Kubernetes
[daemonsets](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/),
most situations will call for a more nuanced approach. For instance, it is perfectly possible to have
Prometheus monitor __itself__, but in normal circumstances this is not really desirable. Or optimal.
Or even all that useful. However, daemonsets do make a lot of sense for installing
loggers.


#### Label Namespace

Verify no namespaces are annotated as follows:

    $ kubectl get namespace -L istio-injection
    NAME           STATUS    AGE       ISTIO-INJECTION
    default        Active    21d
    istio-system   Active    15m       
    kube-public    Active    21d       
    kube-system    Active    21d       
    $

Launch a pod:

    $ kubectl apply -f samples/sleep/sleep.yaml

Label the `default` namespace with `istio-injection=enabled`:

    $ kubectl label namespace default istio-injection=enabled

Verify `default` namespace has been annotated as follows:

    $ kubectl get namespace -L istio-injection
    NAME           STATUS    AGE       ISTIO-INJECTION
    default        Active    21d       enabled
    istio-system   Active    15m
    kube-public    Active    21d
    kube-system    Active    21d
    $

Kill the existing `sleep` pod:

    $ kubectl delete po/sleep-776b7bcdcd-dpnlq

Verify that it respawns with a sidecar:

    $ kubectl get pod
    NAME                            READY     STATUS        RESTARTS   AGE
    sleep-776b7bcdcd-dpnlq          1/1       Terminating   0          8m
    sleep-776b7bcdcd-p2gts          0/2       Init:0/1      0          3s
    $


#### Annotate Deployment

Annotate deployments for sidecar (envoy) injection as follows:

    $ kubectl annotate po sleep-776b7bcdcd-s5c5g sidecar.istio.io/inject=true

OR

    $ kubectl annotate po sleep-776b7bcdcd-s5c5g sidecar.istio.io/inject=false

OR

    $ kubectl annotate po sleep-776b7bcdcd-s5c5g sidecar.istio.io/inject=true --overwrite

[Can also be applied via YAML or JSON.]

Remove annotation with:

    $ kubectl annotate po sleep-776b7bcdcd-s5c5g sidecar.istio.io/inject-

And delete pod:

    $ kubectl delete -f samples/sleep/sleep.yaml


## Addons

Install any desired addons (Prometheus, Grafana, Zipkin) as follows:

    $ kubectl apply -f install/kubernetes/addons/prometheus.yaml

[In order to have Grafana it seems to be necessary to install Prometheus first.]

We are using __minikube__ and will want to access Grafana, so edit
`install/kubernetes/addons/grafana.yaml`, change the Service type
from `ClusterIP` to `NodePort`, and save it as `../grafana.yaml`.

[And the same for `install/kubernetes/addons/zipkin.yaml`.]

Can then run it as follows:

    $ kubectl apply -f ../grafana.yaml

Can then open our Grafana dashboard as follows:

    $ minikube service --url grafana -n istio-system


Can now proceed to [Final teardown](09-Teardown.md).


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
