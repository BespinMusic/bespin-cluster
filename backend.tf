resource "kubernetes_pod" "backend-server" {
  metadata {
    name = "backend-server"
    labels {
      App = "backend"
    }
  }

  spec {
    container {
      image = "127.0.0.1:5000/backend-server:1"
      name  = "backend-server"

      port {
        container_port = 8000
      }
      env {
        name = "LOCAL_PORT"
        value = 8000
      }
      env {
        name = "APP_DB_HOST"
        value = "backend-db"
      }
      env {
        name = "APP_DB_PORT"
        value = 6000
      }
      env {
        name = "APP_DB_NAME"
        value = "bespin"
      }
      env {
        name = "APP_DB_USERNAME"
        value = "postgres"
      }

    }
  }
}

resource "kubernetes_service" "backend-server" {
  metadata {
    name = "backend-server"
  }
  spec {
    selector {
      App = "${kubernetes_pod.backend-server.metadata.0.labels.App}"
    }
    port {
      port = 7000
      target_port = 8000
    }

  }
}

