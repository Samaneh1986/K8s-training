variable "clusterId" {
  type        = string
  description = "The id of the target K8s  cluster in Rancher."
}
variable "DBuser" {
  type        = string
}
variable "DBpass" {
  type        = string
}
variable "DBrootHost" {
  type        = string
}
variable "DBrootPass" {
  type        = string
}

data "rancher2_project" "targetPrj" {
    cluster_id = var.clusterId
    name = "your-target-project-in-Rancher"
}
