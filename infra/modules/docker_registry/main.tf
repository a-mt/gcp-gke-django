
# ${var.gcp_project_number}-compute@developer.gserviceaccount.com
data "google_compute_default_service_account" "default" {
}

#+-------------------------------------
#| REPOSITORY
#+-------------------------------------

# Create a Docker Images repository
resource "google_artifact_registry_repository" "docker_registry" {
  repository_id = var.repository_name
  description   = "Docker repository"
  format        = "DOCKER"
}

# Add IAM policy binding to the default compute service account (allow to read)
resource "google_artifact_registry_repository_iam_binding" "docker_registry_read" {
  project    = google_artifact_registry_repository.docker_registry.project
  location   = google_artifact_registry_repository.docker_registry.location
  repository = google_artifact_registry_repository.docker_registry.name
  role       = "roles/artifactregistry.reader"

  members = [
    "serviceAccount:${data.google_compute_default_service_account.default.email}",
  ]
}

#+-------------------------------------
#| SERVICE ACCOUNT
#+-------------------------------------

# Create a Service account to push images
resource "google_service_account" "docker_registry_write" {
  account_id   = "${google_artifact_registry_repository.docker_registry.repository_id}-write"
  display_name = "Docker Write"
}

# Add IAM policy binding to the service account (allow to write)
resource "google_artifact_registry_repository_iam_binding" "docker_registry_write" {
  project    = google_artifact_registry_repository.docker_registry.project
  location   = google_artifact_registry_repository.docker_registry.location
  repository = google_artifact_registry_repository.docker_registry.name
  role       = "roles/artifactregistry.writer"

  members = [
    "serviceAccount:${google_service_account.docker_registry_write.email}",
  ]
}

# Create a JSON key to authenticate as this Service account
resource "google_service_account_key" "docker_registry_write_json_key" {
  service_account_id = google_service_account.docker_registry_write.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}
