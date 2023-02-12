resource "kubernetes_deployment" "whoami" {
  metadata {
    name = "whoami"
    labels = {
      "app.kubernetes.io/name" = "whoami"
    }
  }
  spec {
    replicas = 3
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "whoami"
      }
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "whoami"
        }
      }
      spec {
        container {
          name  = "whoami"
          image = "traefik/whoami"
          port {
            container_port = 8080
          }
          resources {
            limits = {
              memory = "32M"
              cpu    = "25m"
            }
          }
          args = [
            "--port",
            "8080",
          ]
        }
        security_context {
          run_as_user = 1000
        }
      }
    }
  }
  depends_on = [minikube_cluster.minikube]
}

resource "kubectl_manifest" "whoami_strip" {
  yaml_body = <<YAML
    apiVersion: traefik.containo.us/v1alpha1
    kind: Middleware
    metadata:
      name: whoami-strip
    spec:
      stripPrefix:
        prefixes:
          - /whoami
  YAML
  depends_on = [minikube_cluster.minikube]
}

resource "kubernetes_service" "whoami" {
  metadata {
    name = "whoami"
  }

  spec {
    port {
      name = "api"
      port = 80
      target_port = 8080
    }
    selector = {
      "app.kubernetes.io/name" = "whoami"
    }
  }
  depends_on = [minikube_cluster.minikube]
}

resource "kubernetes_ingress_v1" "whoami" {
  metadata {
    name = "whoami"
    annotations = {
      "kubernetes.io/ingress.class" = "traefik",
      "traefik.ingress.kubernetes.io/router.tls" = "true"
      "traefik.ingress.kubernetes.io/router.middlewares" = "default-whoami-strip@kubernetescrd"
    }
  }
  spec {
    tls {
      hosts = [
        "localhost",
      ]
    }
    rule {
      host = "localhost"
      http {
        path {
          backend {
            service {
              name = "whoami"
              port {
                number = 80
              }
            }
          }
          path = "/whoami"
        }
      }
    }
  }
  depends_on = [minikube_cluster.minikube]
}