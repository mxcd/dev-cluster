# resource "kubernetes_namespace" "argocd" {
#   metadata {
#     name = var.argocd_namespace
#   }
#   depends_on = [minikube_cluster.docker]
# }

# data "http" "argocd_manifests" {
#   url = "https://raw.githubusercontent.com/argoproj/argo-cd/v${var.argocd_version}/manifests/install.yaml"
# }

# locals {
#   argocd_manifests = split("\n---\n", data.http.argocd_manifests.response_body)
# }

# resource "kubectl_manifest" "argocd" {
#   count = length(local.argocd_manifests)
#   yaml_body = element(local.argocd_manifests, count.index)
#   override_namespace = var.argocd_namespace
#   depends_on = [kubernetes_namespace.argocd]
# }
