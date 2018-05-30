provider "kubernetes" {}

resource "kubernetes_pod" "nginx" {
  metadata {
    name = "nginx-example"
    labels {
      App = "nginx"
    }
  }

  spec {
    container {
      image = "127.0.0.1:5000/web-frontend:1"
      name  = "example"

      port {
        container_port = 3000
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx-example"
  }
  spec {
    selector {
      App = "${kubernetes_pod.nginx.metadata.0.labels.App}"
    }
    port {
      port = 80
      target_port = 3000
    }

    type = "LoadBalancer"
  }
}

