resource "azurerm_resource_group" "example" {
  name     = "rg_example"
  location = "australiaeast"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet_example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "sn_example"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_container_registry" "example" {
  name                = "acrexample"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Premium"
  admin_enabled       = false
}

module "aks" {
  source = "../.."

  resource_group_name = "it-aue1-pit-arg-aks"
  location            = "australiaeast"

  tags = {
    Environment = "nonprod"
    Owner       = "chris.carr@lab3.com.au"
  }

  name                      = "example_aks"
  automatic_channel_upgrade = "node-image"
  dns_prefix                = "DAWE"
  availability_zones        = ["1", "2", "3"]
  dns_service_ip            = "192.168.0.2"
  service_cidr              = "192.168.0.0/24"
  docker_bridge_cidr        = "172.16.0.1/21"
  node_resource_group       = "rg-aks-nodes"
  aks_subnet_id             = azurerm_subnet.example.id

  private_cluster_enabled = true
  private_dns_zone_id     = "/subscriptions/xxxxx-xxxxxx-xxxxxx-xxxxxx/resourceGroups/example/providers/Microsoft.Network/privateDnsZones/privatelink.australiaeast.azmk8s.io"
  admin_group_object_ids  = ["e46ffaf3-bdd0-4315-9ea2-c51537b2ff35"]
  cluster_node_pool_name  = "internal"

  user_assigned_identity_ids = []
  acr_id                     = azurerm_container_registry.example.id

  namespaces = ["nginx", "app"]
  environments = ["dev", "tst"]
  namespace_config = {
    "nginx-dev" = {
        something="value"
    }
    "nginx-tst" = {
        something="value"
    }
  }
}
