resource "google_artifact_registry_repository" "nexus" {
  location      = var.region
  repository_id = var.ar_repo_name
  format        = "DOCKER"
  description   = "Custom Nexus images"

  depends_on = [google_project_service.services]
}
