# helm repo add argo https://argoproj.github.io/argo-helm
# helm repo update
# helm install updater -n argocd argo/argocd-image-updater --version 0.8.4 -f terraform/values/image-updater.yaml
resource "helm_release" "updater" {
  name             = "updater"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argocd-image-updater"
  namespace        = "argocd"
  create_namespace = true
  version          = var.argocd_image_updater_chart_version

  values = [file("${path.module}/values/image-updater.yaml")]

  depends_on = [var.aws_auth_configmap]
}
