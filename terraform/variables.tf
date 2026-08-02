variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "cluster_name" {
  type    = string
  default = "nexus-cluster"
}

variable "node_machine_type" {
  type    = string
  default = "n1-standard-1"
}

variable "bucket_name" {
  type = string
}

variable "bucket_location" {
  type    = string
  default = "US"
}

variable "ar_repo_name" {
  type    = string
  default = "nexus"
}

variable "gsa_name" {
  type    = string
  default = "nexus-gcs"
}

variable "k8s_namespace" {
  type    = string
  default = "nexus"
}

variable "k8s_service_account" {
  type    = string
  default = "nexus"
}
