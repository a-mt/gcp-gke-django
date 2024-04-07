
# Instance connection (for Cloud SQL Proxy)
output "postgres_connection_name" {
  description = "Connection name — ie testing-cloudsql-416715:europe-west1:django-postgres"
  sensitive   = true
  value       = google_sql_database_instance.postgres.connection_name
}

output "postgres_connection_json_key" {
  description = "Connection credentials (base64 encoded)"
  sensitive   = true
  value       = google_service_account_key.cloudsql_sa_json_key.private_key
}

# Database connection
output "postgres_database_name" {
  description = "Database name"
  sensitive   = true
  value       = google_sql_database.db.name
}

output "postgres_database_user" {
  description = "User name"
  sensitive   = true
  value       = google_sql_user.user.name
}

output "postgres_database_password" {
  description = "User password"
  sensitive   = true
  value       = google_sql_user.user.password
}
