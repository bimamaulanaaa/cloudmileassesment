resource "google_project_service" "services" {
  for_each = toset([
    "container.googleapis.com",
    "storage.googleapis.com",
    "artifactregistry.googleapis.com",
  ])

  service            = each.value
  disable_on_destroy = false
}
