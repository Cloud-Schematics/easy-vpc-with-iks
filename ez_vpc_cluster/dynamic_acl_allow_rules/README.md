# Dynamic ACL Allow Rules

This module takes a list of subnet objects and returns a list of ACL rules to use with the `ibm_is_network_acl` block.

## Module Variables

Name    | Type                                                                                                                                                                                                                                                                                                                                            | Description                                                               | Sensitive | Default
------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- | --------- | -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
prefix  | string                                                                                                                                                                                                                                                                                                                                          | A unique identifier need to provision resources. Must begin with a letter |           | fs-refarch-dev
subnets | object({ zone-1 = list(object({ name = string cidr = string vpe = optional(bool) public_gateway = optional(bool) })) zone-2 = list(object({ name = string cidr = string vpe = optional(bool) public_gateway = optional(bool) })) zone-3 = list(object({ name = string cidr = string vpe = optional(bool) public_gateway = optional(bool) })) }) | List of subnets to create ACL rules for                                   |           | { zone-1 = [ { name = "subnet-a" cidr = "10.10.10.0/24" public_gateway = true } ], zone-2 = [ { name = "subnet-b" cidr = "10.20.10.0/24" public_gateway = true } ], zone-3 = [ { name = "subnet-c" cidr = "10.30.10.0/24" public_gateway = true } ] }

## Examnple Usage

```hcl-terraform
module edge_acl_rules {
  source   = "./dynamic_acl_allow_rules"
  prefix   = var.prefix
  subnets  = var.subnets
}
```
