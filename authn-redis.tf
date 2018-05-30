# variable "mysql_password" {}
variable "redis_version" {
  default = "latest"
}

resource "kubernetes_service" "redis" {
  metadata {
    name = "authn-redis"
    labels {
      app = "authn"
    }
  }
  spec {
    port {
      port = 6379
      target_port = 6379
    }
    selector {
      app = "authn"
      tier = "${kubernetes_replication_controller.redis.spec.0.selector.tier}"
    }
    cluster_ip = "None"
  }
}

resource "kubernetes_replication_controller" "redis" {
  metadata {
    name = "authn-redis"
    labels {
      app = "authn"
    }
  }
  spec {
    selector {
      app = "authn"
      tier = "redis"
    }
    template {
      container {
        image = "redis:${var.redis_version}"
        name  = "redis"
      }
    }
  }
}