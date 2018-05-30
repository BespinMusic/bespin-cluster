resource "kubernetes_service" "reverse-proxy" {
  metadata {
    name = "reverseproxy"
    labels {
      app = "reverseproxy"
    }
  }
  spec {
    port {
      port = 80
      target_port = 80
    }
    selector {
      app = "reverseproxy"
      tier = "${kubernetes_replication_controller.reverseproxy.spec.0.selector.tier}"
    }
    type = "LoadBalancer"
  }

  depends_on=["kubernetes_service.authn", "kubernetes_service.web-frontend"]
}

resource "kubernetes_replication_controller" "reverseproxy" {
  metadata {
    name = "reverseproxy"
    labels {
      app = "reverseproxy"
    }
  }
  spec {
    selector {
      app = "reverseproxy"
      tier = "reverseproxy"
    }
    template {
      container {
        image = "127.0.0.1:5000/reverseproxy:4"
        name  = "reverseproxy"
      }
    }
  }
}