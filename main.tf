##############################################################################
# IBM Cloud Provider
##############################################################################

provider "ibm" {
  # Comment out for schematics, to run locally uncomment
  # ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  ibmcloud_timeout = 60
}

##############################################################################


##############################################################################
# VPC Module
##############################################################################

module "ez_vpc" {
  source                = "./ez_vpc_cluster"
  prefix                = var.prefix
  region                = var.region
  resource_group        = var.resource_group
  zones                 = var.zones
  tags                  = var.tags
  use_public_gateways   = var.use_public_gateways
  allow_inbound_traffic = var.allow_inbound_traffic
  classic_access        = var.classic_access
  override_json         = var.override ? file("${path.module}/override.json") : "{}"
}

##############################################################################