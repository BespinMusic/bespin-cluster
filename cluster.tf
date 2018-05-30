provider "kubernetes" {}

resource "kubernetes_pod" "web-frontend" {
  metadata {
    name = "web-frontend"
    labels {
      App = "web"
    }
  }

  spec {
    container {
      image = "127.0.0.1:5000/web-frontend:2"
      name  = "web-frontend"

      port {
        container_port = 3000
      }
    }
  }
}

resource "kubernetes_service" "web-frontend" {
  metadata {
    name = "web-frontend"
  }
  spec {
    selector {
      App = "${kubernetes_pod.web-frontend.metadata.0.labels.App}"
    }
    port {
      port = 4000
      target_port = 3000
    }

  }
}

