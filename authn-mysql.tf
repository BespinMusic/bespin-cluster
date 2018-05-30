# variable "mysql_password" {}
variable "mysql_version" {
  default = "5.7"
}
variable "mysql_dbname" {
  default = "authn"
}

resource "kubernetes_service" "mysql" {
  metadata {
    name = "authn-db-mysql"
    labels {
      app = "authn"
    }
  }
  spec {
    port {
      port = 3306
      target_port = 3306
    }
    selector {
      app = "authn"
      tier = "${kubernetes_replication_controller.mysql.spec.0.selector.tier}"
    }
    cluster_ip = "None"
  }
}

resource "kubernetes_persistent_volume_claim" "mysql" {
  metadata {
    name = "mysql-pv-claim"
    labels {
      app = "authn"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests {
        storage = "20Gi"
      }
    }
  }
}

# resource "kubernetes_secret" "mysql" {
#   metadata {
#     name = "mysql-pass"
#   }

#   data {
#     password = "${var.mysql_password}"
#   }
# }

resource "kubernetes_replication_controller" "mysql" {
  metadata {
    name = "authn-db-mysql"
    labels {
      app = "authn"
    }
  }
  spec {
    selector {
      app = "authn"
      tier = "mysql"
    }
    template {
      container {
        image = "mysql:${var.mysql_version}"
        name  = "mysql"

        # env {
        #   name = "MYSQL_ROOT_PASSWORD"
        #   value_from {
        #     secret_key_ref {
        #       name = "${kubernetes_secret.mysql.metadata.0.name}"
        #       key = "password"
        #     }
        #   }
        # }

        env {
          name="MYSQL_ALLOW_EMPTY_PASSWORD"
          value="yes"
        }

        env {
          name="MYSQL_DATABASE"
          value="${var.mysql_dbname}"
        }

        port {
          container_port = 3306
          name = "mysql"
        }

        volume_mount {
          name = "mysql-persistent-storage"
          mount_path = "/var/lib/mysql"
        }
      }

      volume {
        name = "mysql-persistent-storage"
        persistent_volume_claim {
          claim_name = "${kubernetes_persistent_volume_claim.mysql.metadata.0.name}"
        }
      }
    }
  }
}