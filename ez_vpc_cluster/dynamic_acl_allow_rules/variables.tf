##############################################################################
# ACL Variables
##############################################################################

variable "prefix" {
  description = "A unique identifier need to provision resources. Must begin with a letter"
  type        = string

  validation {
    error_message = "Unique ID must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix))
  }
}

variable "subnets" {
  description = "List of subnets to create ACL rules for"
  type = object({
    zone-1 = list(object({
      name           = string
      cidr           = string
      vpe            = optional(bool)
      public_gateway = optional(bool)
    }))
    zone-2 = list(object({
      name           = string
      cidr           = string
      vpe            = optional(bool)
      public_gateway = optional(bool)
    }))
    zone-3 = list(object({
      name           = string
      cidr           = string
      vpe            = optional(bool)
      public_gateway = optional(bool)
    }))
  })
  default = {
    zone-1 = [
      {
        name           = "subnet-a"
        cidr           = "10.10.10.0/24"
        public_gateway = true
      }
    ],
    zone-2 = [
      {
        name           = "subnet-b"
        cidr           = "10.20.10.0/24"
        public_gateway = true
      }
    ],
    zone-3 = [
      {
        name           = "subnet-c"
        cidr           = "10.30.10.0/24"
        public_gateway = true
      }
    ]
  }

  validation {
    error_message = "Keys for `subnets` must be in the order `zone-1`, `zone-2`, `zone-3`."
    condition     = keys(var.subnets)[0] == "zone-1" && keys(var.subnets)[1] == "zone-2" && keys(var.subnets)[2] == "zone-3"
  }
}

##############################################################################