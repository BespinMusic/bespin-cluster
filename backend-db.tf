resource "kubernetes_service" "backend-db" {
  metadata {
    name = "backend-db"
    labels {
      app = "backend"
    }
  }
  spec {
    port {
      port = 6000
      target_port = 5432
    }
    selector {
      app = "backend"
      tier = "${kubernetes_replication_controller.backend_db.spec.0.selector.tier}"
    }
  }
}

resource "kubernetes_persistent_volume_claim" "backend-db" {
  metadata {
    name = "backend-db-pv-claim"
    labels {
      app = "backend"
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

resource "kubernetes_replication_controller" "backend_db" {
  metadata {
    name = "backend-db"
    labels {
      app = "backend"
    }
  }
  spec {
    selector {
      app = "backend"
      tier = "backend-db"
    }
    template {
      container {
        image = "postgres"
        name = "postgres"

        env {
          name = "POSTGRES_DB"
          value = "bespin"
        }
        env {
          name = "PGDATA"
          value = "/var/lib/postgresql/data/pgdata"
        }
        env {
          name = "POSTGRES_USER"
          value = "postgres"
        }

        port {
          container_port = 5432
        }

        # volume_mount {
        #   name = "postgres-persistent-storage"
        #   mount_path = "/var/lib/postgresql/data"
        # }
      }

      volume {
        name = "postgres-persistent-storage"
        persistent_volume_claim {
          claim_name = "${kubernetes_persistent_volume_claim.backend-db.metadata.0.name}"
        }
      }
    }
  }
}


