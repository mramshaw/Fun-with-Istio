# Fun with Istio

[Istio](https://istio.io/) is a very useful ___service mesh___.
As such, it handles service-to-service communications.

It comes with addons, such as [Prometheus](https://prometheus.io/), [Grafana](https://grafana.com/)
and [Zipkin](https://zipkin.io/).

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


## Plan of Attack

The plan of attack is as follows:

* [Install Istio](01-Install-Istio.md)
* [Final teardown](09-Teardown.md)
* [Software Versions](#versions)
* [Still To Do](#to-do)

Can now proceed to [Install Istio](01-Install-Istio.md).


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
