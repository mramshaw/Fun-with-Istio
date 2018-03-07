# Fun with Istio

[Istio](https://istio.io/) is a very useful ___service mesh___.

Having played with the [0.1.6 release](https://github.com/mramshaw/istio-ingress-tutorial),
it seemed to be time to take another look at Istio and the current __0.6__ release.

## Istio pod spec requirements

Istio imposes some requirements (and suggestions) on pod specifications.

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

https://istio.io/docs/setup/kubernetes/sidecar-injection.html

## Istio requirements

1. Kubernetes 1.9 features mutating webhooks, which are enabled by default.

    [Manual proxy injection can be used for earlier versions of Kubernetes.]

2. Minikube version v0.25.0 or later is required for Kubernetes v1.9.
