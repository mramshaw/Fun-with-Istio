# Istio Addons

Istio comes with some very useful addons, such as [Prometheus](https://prometheus.io/),
[Grafana](https://grafana.com/) and [Zipkin](https://zipkin.io/).

## Install Addons

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
