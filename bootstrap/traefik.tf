#Create a namespace ingress
resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress"
  }
  depends_on = [minikube_cluster.minikube]
}

# data "local_file" "traefik_crd" {
#   filename = "${path.module}/traefik-crd.yml"
# }

# locals {
#   traefik_crd = split("\n---\n", data.local_file.traefik_crd.content)
# }

# resource "kubectl_manifest" "traefik_crd" {
#   count = length(local.traefik_crd)
#   yaml_body = element(local.traefik_crd, count.index)
#   depends_on = [kubernetes_namespace.ingress]
# }

# resource "kubectl_manifest" "ingress_class" {
#   yaml_body = <<YAML
#     apiVersion: networking.k8s.io/v1
#     kind: IngressClass
#     metadata:
#       name: traefik
#     spec:
#       controller: traefik.io/ingress-controller
#   YAML
#   depends_on = [kubectl_manifest.traefik_crd]
# }

# data "local_file" "traefik" {
#   filename = "${path.module}/traefik.yml"
# }

# locals {
#   traefik = split("\n---\n", data.local_file.traefik.content)
# }

# resource "kubectl_manifest" "traefik" {
#   count = length(local.traefik)
#   yaml_body = element(local.traefik, count.index)
#   depends_on = [kubectl_manifest.ingress_class]
# }

# resource "kubernetes_config_map" "traefik" {
#   metadata {
#     name = "traefik-config"
#     namespace = "ingress"
#   }
#   data = {
#     "traefik.yml" = <<EOF
#       tls:
#         certificates:
#           - certFile: /ssl/localhost.pem
#             keyFile: /ssl/localhost-key.pem
#             stores:
#               - default
#       entryPoints:
#         web:
#           address: :80
#           http:
#             redirections:
#               entryPoint:
#                 to: websecure
#                 scheme: https
#         websecure:
#           address: :443
#       EOF
#       "localhost.pem" = "${file("localhost.pem")}"
#       "localhost-key.pem" = "${file("localhost-key.pem")}"
#   }
#   depends_on = [kubectl_manifest.ingress_class]
# }

resource "kubectl_manifest" "default_cert" {
  yaml_body = <<YAML
    apiVersion: traefik.containo.us/v1alpha1
    kind: TLSStore
    metadata:
      name: default
      namespace: ingress
    spec:
      defaultCertificate:
        secretName: mkcert
  YAML
  depends_on = [kubernetes_namespace.ingress]
}

resource "kubectl_manifest" "traefik_service" {
  yaml_body = <<YAML
    apiVersion: v1
    kind: Service
    metadata:
      name: traefik
      namespace: ingress
      labels:
        app.kubernetes.io/name: traefik
    spec:
      type: LoadBalancer
      selector:
        app.kubernetes.io/name: traefik
      ports:
        - port: 80
          name: web
          targetPort: "web"
          protocol: "TCP"
        - port: 443
          name: websecure
          targetPort: "websecure"
          protocol: "TCP"
  YAML
  depends_on = [kubernetes_namespace.ingress]
}

resource "kubernetes_secret_v1" "mkcert" {
  metadata {
    name = "mkcert"
    namespace = "ingress"
  }

  data = {
    "tls.crt" = "${file("${path.module}/localhost.pem")}"
    "tls.key" = "${file("${path.module}/localhost-key.pem")}"
  }
  depends_on = [kubernetes_namespace.ingress]
}

resource "helm_release" "traefik" {
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  # version    = "21.0.0"
  name       = "traefik"
  namespace  = "ingress"
  create_namespace = true
  set {
    name  = "replicas"
    value = "2"
  }

  set {
    name  = "tracing.backend"
    value = "jaeger"
  }

  set {
    name  = "tracing.enabled"
    value = "true"
  }

  set {
    name = "ssl.enabled"
    value = "true"
  }
  set {
    name = "ssl.enforced"
    value = "true"
  }
  set {
    name = "service.enabled"
    value = "false"
  }
  # set {
  #   name = "ssl.defaultCert"
  #   value = "${file("${path.module}/localhost.pem")}"
  # }
  # set {
  #   name = "ssl.defaultKey"
  #   value = "${file("${path.module}/localhost-key.pem")}"
  # }

  # set {
  #   name = "additionalConfig"
  #   value = <<EOF
  #     tls:
  #     stores:
  #       default:
  #         defaultCertificate:
  #           certFile: '/certs/tls.crt'
  #           keyFile: '/certs/tls.key'
  #     EOF
  # }
  # set {
  #   name = "service.ports.web.nodePort"
  #   value = "80"
  # }
  # set {
  #   name = "service.ports.websecure.nodePort"
  #   value = "443"
  # }
  # set {
  #   name = "nodeSelector.ingress"
  #   value = "here"
  # }

  set {
    name = "dashboard.enabled"
    value = "true"
  }
  set {
    name = "dashboard.auth"
    value = "{}"
  }

  depends_on = [minikube_cluster.minikube]
}