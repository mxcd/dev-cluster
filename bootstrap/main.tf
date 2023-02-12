terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 1.13.0"
    }

    sops = {
      source = "carlpett/sops"
      version = "~> 0.5"
    }

    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }

    helm = {
      source = "hashicorp/helm"
      version = "2.8.0"
    }

    minikube = {
      source = "scott-the-programmer/minikube"
      version = "0.1.0"
    }
  }
}

# provider "minikube" {
#   kubernetes_version = "v1.25.3"
# }

# resource "null_resource" "minikube" {
#   provisioner "local-exec" {
#     command = <<EOF
#       minikube start --driver=docker --mount --mount-string=${var.project_base}/bootstrap/data:/srv --addons=default-storageclass
#       sleep 10
#       kubectl -n kube-system rollout status deployment coredns
#       echo Waiting for minikube to be ready...
#       echo Please stand by for one minute
#       sleep 60
#     EOF
#   }
# }

resource "minikube_cluster" "minikube" {
  driver       = "docker"
  cluster_name = "minikube"
  wait         = ["apiserver"]
  # mount        = true
  # mount_string = "${var.project_base}/bootstrap/data:/srv"
  addons = [
    "default-storageclass",
  ]
}

provider "kubernetes" {
  # config_path            = "~/.kube/config"
  host                   = minikube_cluster.minikube.host
  client_certificate     = minikube_cluster.minikube.client_certificate
  client_key             = minikube_cluster.minikube.client_key
  cluster_ca_certificate = minikube_cluster.minikube.cluster_ca_certificate
}

provider "kubectl" {
  # config_path            = "~/.kube/config"
  load_config_file = "false"
  host                   = minikube_cluster.minikube.host
  client_certificate     = minikube_cluster.minikube.client_certificate
  client_key             = minikube_cluster.minikube.client_key
  cluster_ca_certificate = minikube_cluster.minikube.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    # config_path            = "~/.kube/config"
    host                   = minikube_cluster.minikube.host
    client_certificate     = minikube_cluster.minikube.client_certificate
    client_key             = minikube_cluster.minikube.client_key
    cluster_ca_certificate = minikube_cluster.minikube.cluster_ca_certificate
  }
}