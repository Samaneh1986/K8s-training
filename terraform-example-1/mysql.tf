variable "clusterId" {
  type        = string
  description = "The id of the target K8s  cluster in Rancher."
}
variable "projectId" {
  type        = string
  description = "The id of the target K8s project in Rancher."
}

resource "rancher2_catalog_v2" "mysql-operator" {
  cluster_id = var.clusterId
  name = "mysql-operator"
  url = "https://mysql.github.io/mysql-operator/"
}

resource "rancher2_app_v2" "mysql-operator" {
  depends_on = [rancher2_catalog_v2.mysql-operator]
  cluster_id = var.clusterId
  name = "mysql-operator"
  namespace = "mysql-operator"
  repo_name = "mysql-operator"
  chart_name = "mysql-operator"
  project_id = var.projectId
}


resource "kubectl_manifest" "mysql-db-1" {
    yaml_body = <<YAML
apiVersion: mysql.oracle.com/v2
kind: InnoDBCluster
metadata:
  name: mysql-db-1
  namespace: mysql-operator
spec:
  secretName: mypwds
  tlsUseSelfSigned: true
  version: "8.0.29"
YAML
}  
