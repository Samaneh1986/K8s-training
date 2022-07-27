terraform {
  required_providers {
    rancher2 = {
      source = "rancher/rancher2"
      version = "1.24.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}
provider "rancher2" {
  api_url    = "https://rancher.mydomain.com"
}

