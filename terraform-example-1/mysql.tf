resource "rancher2_namespace" "mysql-ns" {
  name = "mysql"
  project_id = data.rancher2_project.targetPrj.id
}

resource "kubernetes_secret" "mySQLdbSec-mysql" {
  depends_on = [rancher2_namespace.mysql-ns]
  metadata {
    name = "mysql-sec"
    namespace = "mysql"
  }
   data = {
    dbUser = var.DBuser
    dbPassword = var.DBpass
  }
}

resource "kubernetes_service" "mysql-srv" {
  depends_on = [rancher2_namespace.mysql-ns]
  metadata {
    name = "wordpress-mysql"
    namespace = "mysql"
    labels = {
      app = "wordpress"
    }
  }
  spec {
    selector = {
      app = "wordpress"
      tier = "mysql"
    }
    port {
      port        = 3306
    }
    type = "ClusterIP"
    cluster_ip = "None"
  }
}

resource "kubernetes_persistent_volume_claim" "mysql-pv-claim" {
  depends_on = [rancher2_namespace.mysql-ns]
  metadata {
    name = "mysql-pv-claim"
    namespace = "mysql"
    labels = {
      app = "wordpress"
    }
  }
  spec {
    resources {
      requests = {
        storage = "2Gi"
      }
    }
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "nfs-storage"
  }
}

resource "kubernetes_deployment" "mysql-dpl" {
  depends_on = [kubernetes_persistent_volume_claim.mysql-pv-claim, kubernetes_secret.mySQLdbSec-mysql]
  metadata {
    name = "wordpress-mysql"
    namespace = "mysql"
    labels = {
      app = "wordpress"
    }
  }

  spec {
    replicas = 1
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        app = "wordpress"
        tier = "mysql"
      }
    }

    template {
      metadata {
        labels = {
          app = "wordpress"
          tier = "mysql"
        }
      }
      spec {
        container {
          image = "mysql:5.6"
          name  = "mysql"
          
          env {
            name = "MYSQL_ROOT_PASSWORD"
            value = var.DBrootPass
          }
          env {
            name = "MYSQL_ROOT_HOST"
            value = var.DBrootHost
          }
          env {
            name = "MYSQL_DATABASE"
            value = "wordpress"
          }
          env {
            name = "MYSQL_USER"
            value_from {
                secret_key_ref {
                  key  = "dbUser"
                  name = "mysql-sec"
                }
            }
          } 
          env {
            name = "MYSQL_PASSWORD"
            value_from {
                secret_key_ref {
                  key  = "dbPassword"
                  name = "mysql-sec"
                }
            }
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
            claim_name = "mysql-pv-claim"
          }
        }
      }
    }
  }
}
