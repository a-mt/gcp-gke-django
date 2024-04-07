
locals {
  docker_registry_repository_region   = google_artifact_registry_repository.docker_registry.location
  docker_registry_repository_project  = google_artifact_registry_repository.docker_registry.project
  docker_registry_repository_name     = google_artifact_registry_repository.docker_registry.name
  docker_registry_repository_hostname = "${local.docker_registry_repository_region}-docker.pkg.dev"
}

output "docker_registry_hostname" {
  description  = "Hostname of the Docker registry — ie REGION-docker.pkg.dev"
  value        = local.docker_registry_repository_hostname
  sensitive    = false
}

output "docker_registry_repository_url" {
  description  = "URL of the repository — ie REGION-docker.pkg.dev/PROJECT_ID/REPO_NAME"
  value        = join("/", [
    local.docker_registry_repository_hostname,
    local.docker_registry_repository_project,
    local.docker_registry_repository_name,
  ])
  sensitive    = false
}

output "docker_registry_write_json_key" {
  value        = google_service_account_key.docker_registry_write_json_key.private_key
  description  = "Credentials to push to the Docker registry"
  sensitive    = true
}
