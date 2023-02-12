data "http" "reloader" {
  url = "https://raw.githubusercontent.com/stakater/Reloader/master/deployments/kubernetes/reloader.yaml"
}

locals {
  reloader_manifests = split("\n---\n", data.http.reloader.response_body)
}

resource "kubectl_manifest" "reloader" {
  count = length(local.reloader_manifests)
  yaml_body = element(local.reloader_manifests, count.index)
  override_namespace = "default"
  depends_on = [minikube_cluster.minikube]
}
