variable "name" {
  description = "(Required) The name of the Managed Kubernetes Cluster to create. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) Specifies the Resource Group where the Managed Kubernetes Cluster should exist. Changing this forces a new resource to be created."
  type        = string
}
variable "location" {
  description = "(Required) The location where the Managed Kubernetes Cluster should be created. Changing this forces a new resource to be created."
  type        = string
}

variable "kubernetes_version" {
  description = "(Optional) Version of Kubernetes specified when creating the AKS managed cluster. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade)."
  type        = string
  default     = null
}

variable "sku_tier" {
  description = "(Optional) The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid (which includes the Uptime SLA). Defaults to Paid. Changing this forces a new resource to be created."
  type        = string
  default     = "Paid"
}

variable "node_resource_group" {
  description = "(Optional) The name of the Resource Group where the Kubernetes Nodes should exist.  Changing this forces a new resource to be created.  Azure requires that a new, non-existent Resource Group is used."
  type        = string
  default     = null
}

variable "dns_prefix" {
  description = "(Required) DNS prefix specified when creating the managed cluster.  The dns_prefix must contain between 3 and 45 characters, and can contain only letters, numbers, and hyphens. It must start with a letter and must end with a letter or a number.  Changing this forces a new resource to be created."
  type        = string
}

variable "private_dns_zone_id" {
  description = "(Optional) Either the ID of Private DNS Zone which should be delegated to this Cluster, Values are System, None, or your private dns zone ID"
  type        = string
  default     = "System"
}
variable "private_cluster_enabled" {
  description = "(Optional) Should this Kubernetes Cluster have its API server only exposed on internal IP addresses? This provides a Private IP Address for the Kubernetes API on the Virtual Network where the Kubernetes Cluster is located. Defaults to true. Changing this forces a new resource to be created."
  type        = bool
  default     = true
}

variable "default_node_pool_name" {
  description = "(Optional) The name which should be used for the default Kubernetes Node Pool. Defaults to default. Changing this forces a new resource to be created."
  type        = string
  default     = "default"
}

variable "vm_size" {
  description = "(Optional) The size of the Virtual Machines that will form the default node pool. Defaults to Standard_D4s_v3."
  type        = string
  default     = "Standard_D4s_v3"
}

variable "availability_zones" {
  description = "(Optional) A list of Availability Zones across which the Node Pool should be spread. Changing this forces a new resource to be created."
  type        = list(string)
  default     = null
}

variable "enable_auto_scaling" {
  description = "(Optional) Should the Kubernetes Auto Scaler be enabled for this Node Pool?  Defaults to true."
  type        = bool
  default     = true
}

variable "node_count" {
  description = "(Optional) The number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 (inclusive). This value is only used when enable_auto_scaling is true. Defaults to 1."
  type        = number
  default     = 1
}

variable "enable_host_encryption" {
  description = "(Optional) Should the nodes in the Default Node Pool have host encryption enabled?  Defaults to false."
  type        = bool
  default     = false
}

variable "enable_node_public_ip" {
  description = "(Optional) Should nodes in this Node Pool have a Public IP Address? Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "max_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  type        = number
  default     = null
}

variable "node_labels" {
  description = "(Optional) A map of Kubernetes labels which should be applied to nodes in the Default Node Pool. Changing this forces a new resource to be created."
  type        = map(string)
  default     = {}
}

variable "orchestrator_version" {
  description = "(Optional) Version of Kubernetes used for the Agents. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade)"
  type        = string
  default     = null
}

variable "os_disk_size_gb" {
  description = "(Optional) The size of the OS Disk which should be used for each agent in the Node Pool. Defaults to 120. Changing this forces a new resource to be created."
  type        = number
  default     = 120
}

variable "node_pool_type" {
  description = "(Optional) The type of Node Pool which should be created. Possible values are AvailabilitySet and VirtualMachineScaleSets. Defaults to VirtualMachineScaleSets."
  type        = string
  default     = "VirtualMachineScaleSets"
}

variable "max_node_count" {
  description = "(Optional) The maximum number of nodes which should exist in this Node Pool. If specified this must be between 1 and 1000. Defaults to 3."
  type        = number
  default     = 3
}

variable "min_node_count" {
  description = "(Optional) The minimum number of nodes which should exist in this Node Pool. If specified this must be between 1 and 1000. Defaults to 1."
  type        = number
  default     = 1
}

variable "aks_subnet_id" {
  description = "(Required) The resource id of the Endpoint Subnet."
  type        = string
}

# Identity Block

variable "identity_type" {
  description = "(Optional) The type of identity used for the managed cluster. Defaults to SystemAssigned. Possible values are SystemAssigned and UserAssigned. If UserAssigned is set, at least one entry must be set in user_assigned_identity_ids as well."
  type        = string
  default     = "SystemAssigned"
}

variable "user_assigned_identity_ids" {
  description = "(Optional) A list of user assigned identity ids."
  type        = list(string)
  default     = []
}

# Add On Profiles Block

variable "http_application_routing_enabled" {
  description = "(Optional) Is HTTP Application Routing Enabled? Defaults to true."
  type        = bool
  default     = false
}

variable "azure_policy_enabled" {
  description = "(Optional) Is the Azure Policy for Kubernetes Add On enabled? Defaults to true."
  type        = bool
  default     = true
}

# variable "log_analytics_workspace_id" {
#   description = "(Optional) The ID of the Log Analytics Workspace which the OMS Agent should send data to. Must be present if enabled is true."
#   type        = string
#   default     = null
# }

variable "secret_rotation_enabled" {
  description = "(Optional) Is secret rotation enabled? Must be present if enabled is true."
  type        = bool
  default     = false
}
variable "secret_rotation_interval" {
  description = "(Optional) The interval to poll for secret rotation. This attribute is only set when secret_rotation is true and defaults to 2m."
  type        = string
  default     = "2m"
}

# Role Based Access Control Block

variable "rbac_enabled" {
  description = "(Optional) Is Role Based Access Control based on Azure AD enabled? Defaults to true."
  type        = bool
  default     = true
}

variable "aad_integration_managed" {
  description = "(Optional) Is the Azure Active Directory integration Managed, meaning that Azure will create/manage the Service Principal used for integration. Defaults to true."
  type        = string
  default     = true
}

variable "tenant_id" {
  description = "(Optional) The Tenant ID used for Azure Active Directory Application. If this isn't specified the Tenant ID of the current Subscription is used."
  type        = string
  default     = null
}

variable "admin_group_object_ids" {
  description = "(Optional) A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster."
  type        = list(string)
  default     = null
}

variable "azure_rbac_enabled" {
  description = "(Optional) Is Role Based Access Control based on Azure AD enabled?"
  type        = bool
  default     = true
}

# Network Profile Block

# variable "network_plugin" {
#   description = "(Optional) Network plugin to use for networking.  Currently supported values are azure and kubenet.  Defaults to azure.  Changing this forces a new resource to be created."
#   type        = string
#   default     = "azure"
# }

# variable "network_policy" {
#   description = "(Optional) Sets up network policy to be used with Azure CNI.  Network policy allows us to control the traffic flow between pods.  Defaults to azure.  Changing this forces a new resource to be created."
#   type        = string
#   default     = "azure"
# }

variable "dns_service_ip" {
  description = "(Optional) IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns). Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "docker_bridge_cidr" {
  description = "(Required) IP address (in CIDR notation) used as the Docker bridge IP address on nodes. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "outbound_type" {
  description = "(Optional) The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are loadBalancer and userDefinedRouting. Defaults to loadBalancer."
  type        = string
  default     = "loadBalancer"
}

variable "service_cidr" {
  description = "(Optional) The Network Range used by the Kubernetes service. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

# Tags Block

variable "tags" {
  description = "(Optional) Tags to apply to the resources where possible."
  type        = map(string)
  default     = null
}

variable "api_server_authorized_ip_ranges" {
  description = "(Optional) The IP ranges to allow for incoming traffic to the server nodes."
  type        = set(string)
  default     = []
}

variable "disk_encryption_set_id" {
  description = "(Optional) The ID of the Disk Encryption Set which should be used for the Nodes and Volumes."
  type        = string
  default     = null
}

variable "automatic_channel_upgrade" {
  description = "(Optional) The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, node-image and stable. Omitting this field sets this value to none."
  type        = string
  default     = "stable"
}
variable "linux_profile" {
  description = "(Optional) define Admin username and SSH key used to log into nodes"
  type = object({
    admin_username = string
    key_data       = string
  })
  default = null
}

# variable "pod_cidr" {
#   description = " (Optional) The CIDR to use for pod IP addresses. This field can only be set when network_plugin is set to kubenet. Changing this forces a new resource to be created."
#   type        = string
#   default     = null
# }

variable "cluster_node_pool_name" {
  description = " (Required) The name of the Node Pool which should be created within the Kubernetes Cluster. Changing this forces a new resource to be created."
  type        = string
}

variable "acr_id" {
  description = " (Required) The resource Id of the Azure Container Registry where container images are stored. The cluster assigned identity will be granted ACRPull access to this ACR."
  type        = string
}

variable "namespaces" {
  description = "(Required) A list of root namespaces that will be created in each environment. The actual namespace will have the environment name added to the end."
  type = set(string)
}

variable "environments" {
  description = "(Required) A list of environments be hosted in this cluster. The environment name will be added to the end of each namespace to differentiate them in the cluster."
  type = set(string)
}

variable "namespace_config" {
  description = "(Required) For each namespace/environment combination, this contains the TODO: config..."
  type = map(object({
    something=string
  }))
}
