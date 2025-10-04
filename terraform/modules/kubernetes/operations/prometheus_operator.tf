resource "helm_release" "prometheus_operator" {
  name = "unpaid_developers-prometheus-operator-release"

  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "metrics"
  create_namespace = true

  # overwrite values
  values = [file("modules/kubernetes/operations/values/custom_config.yaml")]
}