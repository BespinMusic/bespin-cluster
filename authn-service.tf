variable "authn_version" {
  default = "4.7.3"
}

resource "kubernetes_service" "authn" {
  metadata {
    name = "authn"
    labels {
      app = "authn"
    }
  }
  spec {
    port {
      port = 3000
      target_port = 3000
    }
    selector {
      app = "authn"
      tier = "${kubernetes_replication_controller.authn.spec.0.selector.tier}"
    }
    type = "ClusterIP"
  }

  depends_on = ["kubernetes_service.mysql", "kubernetes_service.redis"]
}

resource "kubernetes_replication_controller" "authn" {
  metadata {
    name = "authn"
    labels {
      app = "authn"
    }
  }
  spec {
    selector {
      app = "authn"
      tier = "authn"
    }
    template {
      container {
        image = "keratin/authn-server:1.3.0"
        name  = "authn"

        env {
          name = "DATABASE_URL"
          value = "mysql://root@authn-db-mysql:3306/authn"
        }
        env {
          name = "REDIS_URL"
          value = "redis://authn-redis:6379/0"
        }
        env {
          name = "APP_DOMAINS"
          value = "localhost"
        }
        env {
          name = "AUTHN_URL"
          value = "http://authn:3000"
        }
        env {
          name = "SECRET_KEY_BASE"
          value = "dev-key"
        }
        env {
          name = "PASSWORD_POLICY_SCORE"
          value = "0"
        }
        
        
        command=["/bin/sh"]
        args=["-c", "./authn migrate && ./authn server"]
        port {
          container_port = 3000
          name = "authn"
        }
      }
    }
  }
}