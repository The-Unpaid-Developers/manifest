# helm repo add istio https://istio-release.storage.googleapis.com/charts
# helm repo update
# helm install my-istiod-release -n istio-system --create-namespace istio/istiod --set telemetry.enabled=true --set global.istioNamespace=istio-system
resource "helm_release" "istiod" {
  name = "unpaid-developers-singapore-istiod-release"

  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "istiod"
  namespace        = "istio-system"
  create_namespace = true
  version          = var.istio_chart_version

  values = [
    yamlencode({
      telemetry = {
        enabled = true
      }
      global = {
        istioNamespace = "istio-system"
      }
      meshConfig = {
        # Designate "istio-ingressgateway" as the primary ingress service.
        # "istio-ingressgateway" will be responsible for processing all external traffic entering the cluster.
        # This setting informs Istiod to use the "istio-ingressgateway" service as the main ingress point, 
        # allowing it to correctly apply and manage TLS configurations for secure communication at this entry point.
        ingressService = "istio-ingressgateway"
        # Instruct Istiod to identify and configure Istio Gateway resources labeled as 'gateway' for ingress traffic management.
        # This label-based selection enables Istiod to apply ingress-related configurations and policies to the appropriate Gateway resources, 
        # ensuring the correct handling and routing of incoming traffic.
        ingressSelector = "gateway"
      }
    })
  ]

  depends_on = [helm_release.istio_base, var.aws_auth_configmap]
}
