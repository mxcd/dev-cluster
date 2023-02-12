variable project_base {
  description = "Value of the base path of the cluster repository"
  type = string
}

variable "kubeconfig_path" {
  type    = string
  default = "~/.kube/config"
}

variable argocd_version {
  description = "Value of the ArgoCD version to be deployed"
  type = string
  default = "2.6.0"
}

variable argocd_namespace {
  description = "Value of the Kubernetes namespace where to deploy ArgoCD resources"
  type = string
  default = "argocd"
}

# variable "kubeconfig_path" {
#   type    = string
#   default = "kind.kubeconfig"
# }