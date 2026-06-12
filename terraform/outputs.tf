output "backend_url" {
  description = "Backend API URL"
  value       = "http://localhost:3000"
}

output "admin_panel_url" {
  description = "Admin Panel URL"
  value       = "http://localhost:3001"
}

output "postgres_host" {
  description = "PostgreSQL host"
  value       = docker_container.postgres.name
}

output "redis_host" {
  description = "Redis host"
  value       = docker_container.redis.name
}
