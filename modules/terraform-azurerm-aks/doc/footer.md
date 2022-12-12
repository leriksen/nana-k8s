### Using it in a blueprint

IMPORTANT: We periodically release versions for the components. Since, master branch may have breaking changes, best practice would be to use a released version in form of a tag (e.g. ?ref=x.y.z)

```terraform
module "aks" {
  source                          = "git@gitlab.com:--GITREPONAME--/terraform-azurerm-aks?ref=v1.0"
  name                            = var.aks_name
  resource_group_name             = module.aks_resource_group.name
  kubernetes_version              = var.kubernetes_version
  aks_subnet_id                   = var.aks_subnet_id
  location                        = var.location
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges
  automatic_channel_upgrade       = var.automatic_channel_upgrade
  node_resource_group             = var.node_resource_group
  dns_prefix                      = var.dns_prefix
  availability_zones              = var.availability_zones
  dns_service_ip                  = var.dns_service_ip
  service_cidr                    = var.service_cidr
  docker_bridge_cidr              = var.docker_bridge_cidr
  admin_group_object_ids          = var.admin_group_object_ids
  monitoring_insights_enabled     = var.monitoring_insights_enabled
  log_analytics_workspace_id      = var.log_analytics_workspace_id
  private_cluster_enabled         = var.private_cluster_enabled
  cluster_node_pool_name          = var.cluster_node_pool_name
  outbound_type                   = var.outbound_type

}
```
### Test Vars

A sample list of input vars is located in `tests\vars\input.tfvars`

## Testing

You can use below commands to execute the terraform scripts in local

```bash
terraform init
terraform plan -out QuickstartTerraformTest.tfplan -var-file=.\tests\vars\input.tfvars
terraform apply QuickstartTerraformTest.tfplan
```

### Automated testing

The following set of commands can be executed to execute unit testing and integration testing from your local system.

```bash
go get github.com/stretchr/testify/assert
go get github.com/gruntwork-io/terratest/modules/terraform
go test
```