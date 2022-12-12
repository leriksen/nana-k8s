locals {
  tags = merge({
    "ComponentVersion" : "1.0.0"
  }, var.tags)

  network_plugin = "azure"
  network_policy = "azure"

  all_namespaces = toset([
    for pair in setproduct(var.namespaces, var.environments) : "${pair[0]}-${pair[1]}"
  ])
}