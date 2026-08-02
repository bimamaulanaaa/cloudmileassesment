output "cluster_name" {
  value = google_container_cluster.nexus.name
}

output "cluster_location" {
  value = google_container_cluster.nexus.location
}

output "bucket_name" {
  value = google_storage_bucket.nexus.name
}

output "gsa_email" {
  value = google_service_account.nexus.email
}

output "artifact_registry_repo" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.nexus.repository_id}"
}

output "get_credentials_command" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.nexus.name} --zone ${google_container_cluster.nexus.location} --project ${var.project_id}"
}
