##############################################################################
# Find valid IKS/Roks cluster version
##############################################################################

data "ibm_container_cluster_versions" "cluster_versions" {}

##############################################################################


##############################################################################
# Dynamic Config
##############################################################################

module "dynamic_acl_allow_rules" {
  source  = "./dynamic_acl_allow_rules"
  subnets = local.subnets
  prefix  = var.prefix
}


##############################################################################

##############################################################################
# Local configuration
##############################################################################

locals {
  override = jsondecode(var.override_json)
  ##############################################################################
  # List of subnets for dynamic ACL rule creation
  ##############################################################################
  subnets = lookup(local.override, "subnets", {
    zone-1 = var.allow_inbound_traffic ? [
      {
        name = "allow-all"
        cidr = "0.0.0.0/0"
      },
      {
        name           = "subnet-zone-1"
        cidr           = "10.10.10.0/24"
        public_gateway = true
      }
      ] : [
      {
        name           = "subnet-zone-1"
        cidr           = "10.10.10.0/24"
        public_gateway = true
      }
    ],
    zone-2 = [
      {
        name           = "subnet-zone-2"
        cidr           = "10.20.10.0/24"
        public_gateway = true
      }
    ],
    zone-3 = [
      {
        name           = "subnet-zone-3"
        cidr           = "10.30.10.0/24"
        public_gateway = true
      }
    ]
  })
  ##############################################################################

  ##############################################################################
  # VPC config
  ##############################################################################
  config = {
    vpc_name       = "vpc"
    prefix         = var.prefix
    classic_access = var.classic_access
    ##############################################################################
    # Subnets
    ##############################################################################
    subnets = {
      zone-1 = [
        {
          name           = "subnet-zone-1"
          cidr           = "10.10.10.0/24"
          public_gateway = true
          acl_name       = "acl"
        }
      ],
      zone-2 = [
        {
          name           = "subnet-zone-2"
          cidr           = "10.20.10.0/24"
          public_gateway = true
          acl_name       = "acl"
        }
      ],
      zone-3 = [
        {
          name           = "subnet-zone-3"
          cidr           = "10.30.10.0/24"
          public_gateway = true
          acl_name       = "acl"
        }
      ]
    }
    ##############################################################################

    ##############################################################################
    # ACL rules
    ##############################################################################
    acls = [
      {
        name              = "acl"
        add_cluster_rules = true
        rules = flatten([
          module.dynamic_acl_allow_rules.rules,
          {
            name        = "allow-all-outbound"
            action      = "allow"
            direction   = "outbound"
            destination = "0.0.0.0/0"
            source      = "0.0.0.0/0"
          }
        ])
      }
    ]
    ##############################################################################

    ##############################################################################
    # Public Gateways
    ##############################################################################
    use_public_gateways = {
      zone-1 = var.use_public_gateways ? true : false
      zone-2 = var.use_public_gateways ? true : false
      zone-3 = var.use_public_gateways ? true : false
    }
    ##############################################################################

    ##############################################################################
    # Default VPC Security group rules
    ##############################################################################
    security_group_rules = [
      {
        name      = "allow-all-inbound"
        direction = "inbound"
        remote    = "0.0.0.0/0"
      }
    ]
    ##############################################################################

    ##############################################################################
    # Cluster Variables
    ##############################################################################

    cluster = {
      subnets = [
        "subnet-zone-1", "subnet-zone-2", "subnet-zone-3"
      ]

      name                            = "${var.prefix}-roks-cluster"
      kube_version                    = local.kube_version
      wait_till                       = var.wait_till
      machine_type                    = var.machine_type
      workers_per_zone                = var.workers_per_zone
      disable_public_service_endpoint = var.disable_public_service_endpoint
    }

    ##############################################################################

    
  }

  override_vpc = lookup(local.override, "vpc", {})
  override_cluster = lookup(local.override, "cluster", {})

  env = {
    prefix = lookup(local.override, "prefix", var.prefix)
    vpc = {
      vpc_name                    = lookup(local.override_vpc, "vpc_name", local.config.vpc_name)
      classic_access              = lookup(local.override_vpc, "classic_access", local.config.classic_access)
      network_acls                = lookup(local.override_vpc, "network_acls", local.config.acls)
      use_public_gateways         = lookup(local.override_vpc, "use_public_gateways", local.config.use_public_gateways)
      subnets                     = lookup(local.override_vpc, "subnets", local.config.subnets)
      use_manual_address_prefixes = lookup(local.override_vpc, "use_manual_address_prefixes", null)
      default_network_acl_name    = lookup(local.override_vpc, "default_network_acl_name", null)
      default_security_group_name = lookup(local.override_vpc, "default_security_group_name", null)
      default_routing_table_name  = lookup(local.override_vpc, "default_routing_table_name", null)
      address_prefixes            = lookup(local.override_vpc, "address_prefixes", null)
      routes                      = lookup(local.override_vpc, "routes", [])
      vpn_gateways                = lookup(local.override_vpc, "vpn_gateways", [])
    }
    cluster = {
      name                            = lookup(local.override_cluster, "name", local.config.cluster.name)
      subnets                         = lookup(local.override_cluster, "subnets", local.config.cluster.subnets)
      kube_version                    = lookup(local.override_cluster, "kube_version", local.config.cluster.kube_version)
      wait_till                       = lookup(local.override_cluster, "wait_till", local.config.cluster.wait_till)
      machine_type                    = lookup(local.override_cluster, "machine_type", local.config.cluster.machine_type)
      workers_per_zone                = lookup(local.override_cluster, "workers_per_zone", local.config.cluster.workers_per_zone)
      disable_public_service_endpoint = lookup(local.override_cluster, "disable_public_service_endpoint", local.config.cluster.disable_public_service_endpoint)
    }
  }

  string = "\"${jsonencode(local.env)}\""
}

##############################################################################

##############################################################################
# Convert Environment to escaped readable string
##############################################################################

data "external" "format_output" {
  program = ["python3", "${path.module}/scripts/output.py", local.string]
}

##############################################################################