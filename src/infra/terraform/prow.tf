resource "google_service_account" "prow" {
  account_id   = "prow-service-account"
  display_name = ""
}

resource "google_storage_bucket" "prow" {
  name     = "${var.project_id}"
  location = "asia-northeast1"
}

resource "google_storage_bucket_iam_member" "prow" {
  bucket = "${google_storage_bucket.prow.name}"
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.prow.email}"
}
