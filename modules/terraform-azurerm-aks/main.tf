#
# AKS Module definition file
#

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  kubernetes_version      = var.kubernetes_version
  sku_tier                = var.sku_tier
  dns_prefix              = var.dns_prefix
  private_cluster_enabled = var.private_cluster_enabled
  private_dns_zone_id     = var.private_dns_zone_id
  node_resource_group     = var.node_resource_group

  dynamic "linux_profile" {
    for_each = var.linux_profile[*]
    content {
      admin_username = linux_profile.value.admin_username
      ssh_key {
        key_data = linux_profile.value.key_data
      }
    }
  }

  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges
  disk_encryption_set_id          = var.disk_encryption_set_id
  automatic_channel_upgrade       = var.automatic_channel_upgrade

  default_node_pool {
    name                   = var.default_node_pool_name
    vm_size                = var.vm_size
    zones                  = var.availability_zones
    enable_auto_scaling    = var.enable_auto_scaling
    enable_host_encryption = var.enable_host_encryption
    enable_node_public_ip  = var.enable_node_public_ip
    max_pods               = var.max_pods
    node_labels            = var.node_labels
    orchestrator_version   = var.orchestrator_version
    os_disk_size_gb        = var.os_disk_size_gb
    type                   = var.node_pool_type

    max_count = var.max_node_count
    min_count = var.min_node_count

    vnet_subnet_id = var.aks_subnet_id

    tags = local.tags
  }

  identity {
    type         = var.identity_type
    identity_ids = var.user_assigned_identity_ids
  }

  http_application_routing_enabled = var.http_application_routing_enabled
  azure_policy_enabled             = var.azure_policy_enabled
  key_vault_secrets_provider {
    secret_rotation_enabled  = var.secret_rotation_enabled
    secret_rotation_interval = var.secret_rotation_interval
  }

  # oms_agent {
  #   log_analytics_workspace_id = var.log_analytics_workspace_id
  # }

  role_based_access_control_enabled = var.rbac_enabled
  azure_active_directory_role_based_access_control {
    managed                = var.aad_integration_managed
    tenant_id              = var.tenant_id
    admin_group_object_ids = var.admin_group_object_ids
    azure_rbac_enabled     = var.azure_rbac_enabled
  }

  network_profile {
    network_plugin     = local.network_plugin
    network_policy     = local.network_policy
    dns_service_ip     = var.dns_service_ip
    docker_bridge_cidr = var.docker_bridge_cidr
    outbound_type      = var.outbound_type
    service_cidr       = var.service_cidr
  }
}

# TODO: Same min/max node count in default/internal node pool?
resource "azurerm_kubernetes_cluster_node_pool" "this" {
  name                   = var.cluster_node_pool_name    # TODO: Should this default to "internal"? Will there be multiple node pools?
  kubernetes_cluster_id  = azurerm_kubernetes_cluster.this.id
  vm_size                = var.vm_size
  enable_auto_scaling    = var.enable_auto_scaling
  enable_host_encryption = var.enable_host_encryption
  enable_node_public_ip  = var.enable_node_public_ip
  max_pods               = var.max_pods
  node_labels            = var.node_labels
  orchestrator_version   = var.orchestrator_version
  os_disk_size_gb        = var.os_disk_size_gb
  max_count              = var.max_node_count
  min_count              = var.min_node_count
  vnet_subnet_id         = var.aks_subnet_id

  tags = local.tags
}

# Give AKS Managed Identities ACR Pull permission
resource "azurerm_role_assignment" "role_acrpull" {
  for_each = { for k, v in azurerm_kubernetes_cluster.this.identity : k => v.principal_id }

  scope                = var.acr_id
  role_definition_name = "ACRPull"
  principal_id         = each.value

  # For the newly provisioned Service Principal, skip the Azure Active Directory check which may fail due to replication lag.
  skip_service_principal_aad_check = true
}

resource "kubernetes_namespace" "this" {
  for_each = local.all_namespaces

  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = each.value
  }
}

# Grant permissions at the namespace level on each namespace
resource "kubernetes_role_binding" "namespace_editor_binding" {
  for_each = local.all_namespaces

  metadata {
    name      = "${each.value}-editor-binding"
    namespace = each.value
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "daff-edit"
  }
  # dynamic "subject" {
  #   for_each = each.value.editor_aa_groups
  #   content {
  subject {
      kind      = "Group"
      name      = "${each.value}-namespace-editors"
      api_group = "rbac.authorization.k8s.io"
      namespace = each.value
    # }
  }
}

resource "kubernetes_role_binding" "namespace_viewer_binding" {
  for_each = local.all_namespaces

  metadata {
    name      = "${each.value}-viewer-binding"
    namespace = each.value
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "daff-view"
  }
  # dynamic "subject" {
  #   for_each = each.value.viewer_aa_groups
  #   content {
  subject {
    kind      = "Group"
    name      = "${each.value}-namespace-viewers"
    api_group = "rbac.authorization.k8s.io"
    namespace = each.value
  }
}

