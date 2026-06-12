terraform {
  required_version = ">= 1.5"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

locals {
  network_name = "delivery-network"
}

resource "docker_network" "delivery" {
  name = local.network_name
}

resource "docker_volume" "postgres_data" {
  name = "postgres_data"
}

resource "docker_volume" "redis_data" {
  name = "redis_data"
}

resource "docker_volume" "uploads" {
  name = "delivery_uploads"
}

resource "docker_image" "postgis" {
  name         = "postgis/postgis:15-3.3"
  keep_locally = true
}

resource "docker_image" "redis" {
  name         = "redis:7-alpine"
  keep_locally = true
}

resource "docker_image" "backend" {
  name         = "ghcr.io/${var.github_repository}/backend:latest"
  keep_locally = false
}

resource "docker_image" "admin_panel" {
  name         = "ghcr.io/${var.github_repository}/admin-panel:latest"
  keep_locally = false
}

resource "docker_container" "postgres" {
  image = docker_image.postgis.image_id
  name  = "delivery-postgres"

  env = [
    "POSTGRES_DB=delivery_platform",
    "POSTGRES_USER=postgres",
    "POSTGRES_PASSWORD=${var.db_password}",
  ]

  ports {
    internal = 5432
    external = 5432
  }

  volumes {
    volume_name    = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql/data"
  }

  networks_advanced {
    name = docker_network.delivery.name
  }
}

resource "docker_container" "redis" {
  image = docker_image.redis.image_id
  name  = "delivery-redis"

  ports {
    internal = 6379
    external = 6379
  }

  volumes {
    volume_name    = docker_volume.redis_data.name
    container_path = "/data"
  }

  networks_advanced {
    name = docker_network.delivery.name
  }
}

resource "docker_container" "backend" {
  image = docker_image.backend.image_id
  name  = "delivery-backend"

  env = [
    "NODE_ENV=production",
    "PORT=3000",
    "DB_HOST=delivery-postgres",
    "DB_PORT=5432",
    "DB_NAME=delivery_platform",
    "DB_USER=postgres",
    "DB_PASSWORD=${var.db_password}",
    "REDIS_HOST=delivery-redis",
    "REDIS_PORT=6379",
    "JWT_SECRET=${var.jwt_secret}",
    "JWT_REFRESH_SECRET=${var.jwt_refresh_secret}",
    "STRIPE_SECRET_KEY=${var.stripe_secret_key}",
    "STRIPE_WEBHOOK_SECRET=${var.stripe_webhook_secret}",
    "MERCADO_PAGO_ACCESS_TOKEN=${var.mercadopago_access_token}",
    "CORS_ORIGIN=https://admin.${var.domain}",
    "SMTP_HOST=${var.smtp_host}",
    "SMTP_PORT=${var.smtp_port}",
    "SMTP_USER=${var.smtp_user}",
    "SMTP_PASS=${var.smtp_pass}",
  ]

  ports {
    internal = 3000
    external = 3000
  }

  volumes {
    volume_name    = docker_volume.uploads.name
    container_path = "/app/uploads"
  }

  networks_advanced {
    name = docker_network.delivery.name
  }

  depends_on = [docker_container.postgres, docker_container.redis]
}

resource "docker_container" "admin_panel" {
  image = docker_image.admin_panel.image_id
  name  = "delivery-admin"

  ports {
    internal = 80
    external = 3001
  }

  networks_advanced {
    name = docker_network.delivery.name
  }

  depends_on = [docker_container.backend]
}
