##############################################################################
# Resource Group where VPC Resources Will Be Created
##############################################################################

data "ibm_resource_group" "resource_group" {
  name = var.resource_group
}

##############################################################################


##############################################################################
# Create VPC
##############################################################################

module "vpc" {
  source                      = "./vpc"
  resource_group_id           = data.ibm_resource_group.resource_group.id
  region                      = var.region
  tags                        = var.tags
  prefix                      = local.env.prefix
  vpc_name                    = local.env.vpc.vpc_name
  classic_access              = local.env.vpc.classic_access
  network_acls                = local.env.vpc.network_acls
  use_public_gateways         = local.env.vpc.use_public_gateways
  subnets                     = local.env.vpc.subnets
  use_manual_address_prefixes = local.env.vpc.use_manual_address_prefixes
  default_network_acl_name    = local.env.vpc.default_network_acl_name
  default_security_group_name = local.env.vpc.default_security_group_name
  default_routing_table_name  = local.env.vpc.default_routing_table_name
  address_prefixes            = local.env.vpc.address_prefixes
  routes                      = local.env.vpc.routes
  vpn_gateways                = local.env.vpc.vpn_gateways
}

##############################################################################

##############################################################################
# Object Storage
##############################################################################

locals {
  kube_version = (
    var.iks_cluster_version == "default"
    ? data.ibm_container_cluster_versions.cluster_versions.valid_kube_versions[length(data.ibm_container_cluster_versions.cluster_versions.valid_kube_versions) - 1]
    : var.iks_cluster_version
  )
  cluster_subnets = {
    for subnet in toset(
      local.env.cluster.subnets
    ) :
    (subnet) => [
      for vpc_subnet in module.vpc.subnet_zone_list :
      vpc_subnet if vpc_subnet.name == "${local.env.prefix}-${subnet}"
    ][0]
  }
}

##############################################################################


##############################################################################
# Cluster
##############################################################################

resource "ibm_container_vpc_cluster" "cluster" {
  vpc_id                          = module.vpc.vpc_id
  resource_group_id               = data.ibm_resource_group.resource_group.id
  tags                            = (var.tags != null ? var.tags : null)
  name                            = local.env.cluster.name
  kube_version                    = local.env.cluster.kube_version
  flavor                          = local.env.cluster.machine_type
  disable_public_service_endpoint = local.env.cluster.disable_public_service_endpoint
  worker_count                    = local.env.cluster.workers_per_zone
  dynamic "zones" {
    for_each = local.cluster_subnets
    content {
      subnet_id = zones.value["id"]
      name      = zones.value["zone"]
    }
  }
}

##############################################################################