resource "azurerm_container_app" "app" {
  name                         = "ca-${var.project}-${var.app_name}-${var.environment}"
  resource_group_name          = var.resource_group_name
  container_app_environment_id = var.container_app_environment_id
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]
  }

  registry {
    server   = var.registry_login_server
    identity = var.identity_id
  }

  dynamic "secret" {
    for_each = var.key_vault_secrets
    content {
      name                = secret.value.name
      identity            = var.identity_id
      key_vault_secret_id = secret.value.key_vault_secret_id
    }
  }

  ingress {
    external_enabled           = var.ingress_external_enabled
    target_port                = var.container_port
    transport                  = "auto"
    allow_insecure_connections = false

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = var.app_name
      image  = var.image
      cpu    = var.container_cpu
      memory = var.container_memory

      dynamic "env" {
        for_each = var.env_vars
        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = var.key_vault_secrets
        content {
          name        = upper(replace(env.value.name, "-", "_"))
          secret_name = env.value.name
        }
      }

      readiness_probe {
        transport = "http"
        port      = var.container_port
        path      = var.health_probe_path

        interval_seconds        = 10
        failure_count_threshold = 3
      }
    }

    custom_scale_rule {
      name             = "http-concurrency"
      custom_rule_type = "http"

      metadata = {
        concurrentRequests = tostring(var.http_concurrent_requests_per_replica)
      }
    }
  }

  tags = var.tags
}
