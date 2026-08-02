resource "google_service_account" "nexus" {
  account_id   = var.gsa_name
  display_name = "Nexus GCS blob store"

  depends_on = [google_project_service.services]
}

resource "google_storage_bucket_iam_member" "nexus_object_admin" {
  bucket = google_storage_bucket.nexus.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.nexus.email}"
}

resource "google_service_account_iam_member" "workload_identity" {
  service_account_id = google_service_account.nexus.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/${var.k8s_service_account}]"
}
