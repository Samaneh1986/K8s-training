resource "rancher2_namespace" "wordpress-ns" {
  depends_on = [kubernetes_deployment.mysql-dpl]
  name = "wordpress"
  project_id = data.rancher2_project.targetPrj.id
}

resource "kubernetes_secret" "mySQLdbSec-wordpress" {
  depends_on = [rancher2_namespace.wordpress-ns]
  metadata {
    name = "mysql-sec"
    namespace = "wordpress"
  }
   data = {
    dbUser = var.DBuser
    dbPassword = var.DBpass
  }
}

resource "kubernetes_service" "wordpress-srv" {
  depends_on = [rancher2_namespace.wordpress-ns]
  metadata {
    name = "wordpress"
    namespace = "wordpress"
  }
  spec {
    selector = {
      app = "wordpress"
      tier = "frontend"
    }
    port {
      port        = 80
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_persistent_volume_claim" "wp-pv-claim" {
  depends_on = [rancher2_namespace.wordpress-ns]
  metadata {
    name = "wp-pv-claim"
    namespace = "wordpress"
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

resource "kubernetes_deployment" "wordpress-dpl" {
  depends_on = [kubernetes_persistent_volume_claim.wp-pv-claim, kubernetes_secret.mySQLdbSec-wordpress]
  metadata {
    name = "wordpress"
    namespace = "wordpress"
    labels = {
      app = "wordpress"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "wordpress"
        tier = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "wordpress"
          tier = "frontend"
        }
      }
      spec {
        container {
          image = "wordpress:4.8-apache"
          name  = "wordpress"
          
          env {
            name = "WORDPRESS_DB_HOST"
            value = "wordpress-mysql.mysql"
          }
          env {
            name = "WORDPRESS_DB_NAME"
            value = "wordpress"
          }
          env {
            name = "WORDPRESS_DB_USER"
            value_from {
                secret_key_ref {
                  key  = "dbUser"
                  name = "mysql-sec"
                }
            }
          }
          env {
            name = "WORDPRESS_DB_PASSWORD"
            value_from {
                secret_key_ref {
                  key  = "dbPassword"
                  name = "mysql-sec"
                }
            }
          }
          port {
            container_port = 80
            name = "wordpress"
          }  
          volume_mount {
            name = "wordpress-persistent-storage"
            mount_path = "/var/www/html"
          } 
        }
        volume {
          name = "wordpress-persistent-storage"
          persistent_volume_claim {
            claim_name = "wp-pv-claim"
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress" "wordpresstest"{
  depends_on = [kubernetes_service.wordpress-srv]
  metadata {
    name = "wordpress-test"
    namespace = "wordpress"
  }
  spec {
    rule {
      host = "wordpress.gwdg-test.service.rancher.gwdg.de"
      http {
        path {
          backend {
            service_name = "wordpress"
            service_port = 80
          }
          path = "/"
        }
      }
    }
  }
}
