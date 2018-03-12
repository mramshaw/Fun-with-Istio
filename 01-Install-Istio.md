# Install Istio

There are various options for installing Istio. For this exercise I will use
__minikube__ (a local Kubernetes).

## Starting minikube

To save time, I have created a script `minikube-istio.sh` to launch minikube
with the needed options (the most important are `MutatingAdmissionWebhook` and
`ValidatingAdmissionWebhook` which enable
[automatic sidecar injection](#automatic-sidecar-injection)).

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

Can now proceed to [Istio Addons](02-Istio-Addons.md).


## Credits

This page is mainly copied from:

    https://istio.io/docs/setup/kubernetes/sidecar-injection.html
