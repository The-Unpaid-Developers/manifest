# helm repo add istio https://istio-release.storage.googleapis.com/charts
# helm repo update
# helm install gateway -n istio-ingress --create-namespace istio/gateway

# important note: this creates a load balancer that will NOT be tracked by terraform
# since this load balancer is provisioned by kubernetes and not terraform, it will not be managed by terraform
# thus to delete it, you must delete it manually (using the script)
resource "helm_release" "gateway" {
  name = "unpaid-developers-singapore-istio-gateway"

  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "gateway"
  namespace        = "istio-ingress"
  create_namespace = true
  version          = "1.21.0"

  values = [
    yamlencode({
      # set the name of the service to be "istio-ingressgateway"
      service = {
        name = "istio-ingressgateway"
        annotations = {
          # have the gateway be a network load balancer instead of a classic one
          "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
        }
      }
    })
  ]

  depends_on = [
    helm_release.istio_base,
    helm_release.istiod
  ]

}

resource "time_sleep" "wait_for_ingressgateway" {
  depends_on = [helm_release.gateway]

  create_duration = "60s"
}

data "kubernetes_service" "istio_ingressgateway" {
  metadata {
    name      = "unpaid-developers-singapore-istio-ingressgateway"
    namespace = "istio-ingress"
  }

  depends_on = [time_sleep.wait_for_ingressgateway]
}

