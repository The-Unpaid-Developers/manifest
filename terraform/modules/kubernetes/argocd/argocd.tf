# helm install argocd -n argocd --create-namespace argo/argo-cd --version 5.46.8 -f terraform/values/argocd.yaml
resource "helm_release" "argocd" {
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = var.argocd_chart_version

  # overwrite values
  values = [file("${path.module}/values/argocd.yaml")]

  depends_on = [var.aws_auth_configmap]
}
