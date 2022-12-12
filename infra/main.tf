terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.0"
    }
    azuredevops = {
      source = "microsoft/azuredevops"
      version = ">=0.1.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.16.0"
    }

  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  location = "australiasoutheast"
}

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

provider "azuread" {
  tenant_id = data.azurerm_client_config.current.tenant_id
}

data "azuread_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  location = local.location
  name     = "nana"
}

resource "azurerm_log_analytics_workspace" "law" {
  location            = local.location
  name                = "nana"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_key_vault" "nana" {
  location            = local.location
  name                = "nana-k8s"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_monitor_diagnostic_setting" "kv" {
  name                       = azurerm_key_vault.nana.name
  target_resource_id         = azurerm_key_vault.nana.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  //noinspection MissingProperty
  log {
    category_group = "allLogs"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 365 # azure limit
    }
  }

  //noinspection MissingProperty
  log {
    category_group = "audit"
    enabled        = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 365 # azure limit
    }
  }
}

resource "azurerm_key_vault_access_policy" "admin" {
  key_vault_id = azurerm_key_vault.nana.id
  object_id    = data.azurerm_client_config.current.object_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  secret_permissions = [
    "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
  ]
}

resource "random_string" "mongo_db_username" {
  length      = 8
  min_numeric = 2
  min_special = 2
  min_upper   = 2
  min_lower   = 2
}

resource "random_password" "mongo_db_password" {
  length  = 16
  numeric = false
  special = false
  upper   = false
}

resource "azurerm_key_vault_secret" "username" {
  depends_on = [
    azurerm_key_vault_access_policy.admin
  ]

  key_vault_id = azurerm_key_vault.nana.id
  name         = "mondo-db-username"
  value        = random_string.mongo_db_username.result
}

resource "azurerm_key_vault_secret" "password" {
  depends_on = [
    azurerm_key_vault_access_policy.admin
  ]

  key_vault_id = azurerm_key_vault.nana.id
  name         = "mondo-db-password"
  value        = random_password.mongo_db_password.result
}

resource "azurerm_virtual_network" "vnet" {
  address_space       = ["10.0.0.0/23"]
  location            = azurerm_resource_group.rg.location
  name                = "nana"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "nana-aks"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [cidrsubnet(azurerm_virtual_network.vnet.address_space[0], 2, 0)]
}

#resource "azurerm_kubernetes_cluster" "k8s" {
#  location                  = local.location
#  name                      = "nana"
#  resource_group_name       = azurerm_resource_group.rg.name
#  dns_prefix                = "nana"
#  automatic_channel_upgrade = "stable"
#
#  default_node_pool {
#    name       = "default"
#    node_count = 1
#    vm_size    = "Standard_B2s"
#  }
#
#  identity {
#    type = "SystemAssigned"
#  }
#
#  //noinspection HCLUnknownBlockType
#  oms_agent {
#    log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
#  }
#
#  //noinspection HCLUnknownBlockType
#  key_vault_secrets_provider {
#    secret_rotation_enabled = false
#  }
#
#  http_application_routing_enabled = true
#}

resource "azurerm_monitor_diagnostic_setting" "aks" {
#  name                       = azurerm_kubernetes_cluster.k8s.name
#  target_resource_id         = azurerm_kubernetes_cluster.k8s.id
  name                       = module.aks.name
  target_resource_id         = module.aks.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  //noinspection MissingProperty
  log {
    category_group = "allLogs"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 365 # azure limit
    }
  }

  //noinspection MissingProperty
  log {
    category_group = "audit"
    enabled        = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 365 # azure limit
    }
  }
}

module "aks" {
  source = "../modules/terraform-azurerm-aks"

  name                             = "nana"
  resource_group_name              = azurerm_resource_group.rg.name
  location                         = azurerm_resource_group.rg.location
  dns_prefix                       = "nana"
  aks_subnet_id                    = azurerm_subnet.subnet.id
  http_application_routing_enabled = true
  cluster_node_pool_name           = "internal"
  acr_id                           = azurerm_container_registry.acr.id
  namespaces                       = []
  environments                     = []
  namespace_config                 = {}
  service_cidr                     = cidrsubnet(azurerm_virtual_network.vnet.address_space[0], 2, 1)
  docker_bridge_cidr               = cidrsubnet(azurerm_virtual_network.vnet.address_space[0], 2, 2)
  dns_service_ip                   = "10.0.0.131" # in 10.0.0.0/25, first block of /25
}

resource "azurerm_key_vault_access_policy" "aks" {
  key_vault_id = azurerm_key_vault.nana.id
  object_id    = module.aks.key_vault_secrets_provider
  tenant_id    = data.azurerm_client_config.current.tenant_id

  secret_permissions = [
    "Get", "List"
  ]
}

resource "azurerm_container_registry" "acr" {
  location            = local.location
  name                = "nanaacr"
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"
}

resource "azurerm_role_assignment" "k8s-acr" {
  principal_id                     = module.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

resource "azuredevops_project" "nana" {
  name               = "nana"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"
  description        = "Managed by Terraform"
  features = {
    "pipelines"    = "enabled"
    "repositories" = "disabled"
    "boards"       = "disabled"
    "testplans"    = "disabled"
    "artifacts"    = "disabled"
  }
}

resource "azuread_application" "aad_app" {
  display_name = "nana"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "azdo" {
  application_id               = azuread_application.aad_app.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "azdo" {
  service_principal_id = azuread_service_principal.azdo.object_id
}

resource "azuredevops_serviceendpoint_azurerm" "azurerm" {
  project_id            = azuredevops_project.nana.id
  service_endpoint_name = "AzureRM"
  description           = "Managed by Terraform"

  credentials {
    serviceprincipalid  = azuread_service_principal.azdo.object_id
    serviceprincipalkey = azuread_service_principal_password.azdo.value
  }

  azurerm_spn_tenantid      = data.azurerm_client_config.current.tenant_id
  azurerm_subscription_id   = data.azurerm_client_config.current.subscription_id
  azurerm_subscription_name = data.azurerm_subscription.current.display_name
}

resource "azuredevops_serviceendpoint_azurecr" "acr" {
  project_id                = azuredevops_project.nana.id
  service_endpoint_name     = "AzureCR"
  resource_group            = azurerm_resource_group.rg.name
  azurecr_spn_tenantid      = data.azurerm_client_config.current.tenant_id
  azurecr_name              = azurerm_container_registry.acr.name
  azurecr_subscription_id   = data.azurerm_client_config.current.subscription_id
  azurecr_subscription_name = data.azurerm_subscription.current.display_name
}

resource "azurerm_role_assignment" "azdo-acr" {
  principal_id                     = azuread_service_principal.azdo.object_id
  role_definition_name             = "AcrPush"
  scope                            = azurerm_container_registry.acr.id
}

resource "azuredevops_serviceendpoint_github" "app-code" {
  project_id            = azuredevops_project.nana.id
  service_endpoint_name = "GitHub"
  auth_personal {}
  # auth_personal set with AZDO_GITHUB_SERVICE_CONNECTION_PAT environment variable
}

#  open service connections to all pipelines

resource "azuredevops_resource_authorization" "acr" {
  project_id  = azuredevops_project.nana.id
  resource_id = azuredevops_serviceendpoint_azurecr.acr.id
  authorized  = true
}

resource "azuredevops_resource_authorization" "git" {
  project_id  = azuredevops_project.nana.id
  resource_id = azuredevops_serviceendpoint_github.app-code.id
  authorized  = true
}

resource "azuredevops_build_definition" "min_js_webserver" {
  project_id      = azuredevops_project.nana.id
  name            = "min_js_webserver"
  path            = "\\"
  agent_pool_name = "leiferiksenau-lab3-lappie"
  ci_trigger {
    override {
      batch = true
      branch_filter {
        include = [
          "master",
          "main",
          "release/*",
          "hotfix/*"
        ]
      }
      path_filter {
        include = [
          "applications/min-js-webserver/*"
        ]
      }
    }
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = "leriksen/nana-k8s"
    service_connection_id = azuredevops_serviceendpoint_github.app-code.id
    yml_path              = "applications/min-js-webserver/build.yml"
    branch_name           = "refs/heads/main"
  }
}