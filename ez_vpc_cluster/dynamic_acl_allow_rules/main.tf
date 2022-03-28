##############################################################################
# Use local variable to return CIDR blocks
##############################################################################


locals {
  # Rules to allow all traffic to and from edge VPC CIDR blocks
  allow_rules = flatten([
    # For each zone 
    for zone in ["zone-1", "zone-2", "zone-3"] :
    [
      # For each subnet in that zone
      for subnet in var.subnets[zone] :
      # Create an array with rules to allow traffic to and from that subnet
      [
        {
          name        = "allow-inbound-${var.prefix}-${subnet.name}"
          action      = "allow"
          direction   = "inbound"
          destination = "0.0.0.0/0"
          source      = subnet.cidr
          tcp         = null
          udp         = null
          icmp        = null
        },
        {
          name        = "allow-outbound-${var.prefix}-${subnet.name}"
          action      = "allow"
          direction   = "outbound"
          destination = subnet.cidr
          source      = "0.0.0.0/0"
          tcp         = null
          udp         = null
          icmp        = null
        }
      ]
    ] if var.subnets[zone] != null
  ])

}

output "rules" {
  description = "List of allow rules"
  value       = local.allow_rules
}

##############################################################################