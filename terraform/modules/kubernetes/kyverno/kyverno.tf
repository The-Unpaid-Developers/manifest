# helm repo add kyverno https://kyverno.github.io/kyverno/
# helm repo update
# helm install kyverno kyverno/kyverno -n kyverno --create-namespace --set replicaCount=1
resource "helm_release" "kyverno" {
  name = "unpaid-developers-singapore-kyverno-release"

  repository       = "https://kyverno.github.io/kyverno/"
  chart            = "kyverno"
  namespace        = "kyverno"
  create_namespace = true
  version          = var.kyverno_chart_version

  values = [
    yamlencode({
      replicaCount = 1
    }),
    file("${path.module}/values/tracing.yaml")
  ]

  depends_on = [var.aws_auth_configmap]
}
