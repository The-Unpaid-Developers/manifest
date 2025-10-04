# helm install argocd -n argocd --create-namespace argo/argo-cd --version 5.46.8 -f terraform/values/argocd.yaml
resource "helm_release" "argocd" {
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "5.46.8"

  # overwrite values
  values = [file("${path.module}/values/argocd.yaml")]
}
