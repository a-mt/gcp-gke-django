
#+-------------------------------------
#| DATABASE
#| https://cloud.google.com/solutions/setting-up-cloud-sql-for-postgresql-for-production
#+-------------------------------------

# Create an instance
resource "google_sql_database_instance" "postgres" {
  name                = var.instance_name
  database_version    = var.instance_version
  deletion_protection = false

  # Note: as the "project" and "region" variables are not specified:
  # the provider's variables will be be used instead

  settings {
    tier = var.instance_size
  }

  timeouts {
    create = "20m"
  }
}

# Create a user
resource "google_sql_user" "user" {
  instance = google_sql_database_instance.postgres.name
  name     = var.database_username
  password = var.database_password
}

# Create a database
resource "google_sql_database" "db" {
  instance = google_sql_database_instance.postgres.name
  name     = var.database_name

  # If Terraform tries to delete the user before deleting the database, we get:
  # Error, failed to deleteuser postgres-user in instance django-postgres
  # role "postgres-user" cannot be dropped because some objects depend on it
  # Details: 19 objects in database postgres-db., invalid
  depends_on = [google_sql_user.user]
}

#+-------------------------------------
#| SERVICE ACCOUNT
#+-------------------------------------

# Create a Service account
resource "google_service_account" "cloudsql_sa" {
  account_id   = "${var.instance_name}-connection"
  display_name = "Cloud SQL"
}

# Add roles (to add permissions to clousql_sa)
resource "google_project_iam_member" "cloudsql_sa_roles" {

  # https://gcp.permissions.cloud/iam/cloudsql
  for_each = toset([
    "roles/cloudsql.admin",
    "roles/cloudsql.editor",
    "roles/cloudsql.client",
  ])
  role    = each.key
  member  = "serviceAccount:${google_service_account.cloudsql_sa.email}"
  project = google_sql_database_instance.postgres.project
}

# Create a JSON key (to authenticate locally as clousql_sa)
resource "google_service_account_key" "cloudsql_sa_json_key" {
  service_account_id = google_service_account.cloudsql_sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}
