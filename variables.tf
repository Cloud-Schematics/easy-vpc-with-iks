##############################################################################
# Template Variables
##############################################################################

# Comment out for schematics, to run locally uncomment
# variable "ibmcloud_api_key" {
#   description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
#   type        = string
#   sensitive   = true
# }

variable "TF_VERSION" {
  default     = "1.0"
  type        = string
  description = "The version of the Terraform engine that's used in the Schematics workspace."
}

##############################################################################

##############################################################################
# Account Variables
##############################################################################

variable "prefix" {
  description = "A unique identifier for resources. Must begin with a letter. This prefix will be prepended to any resources provisioned by this template."
  type        = string
  default     = "ez-multizone-iks"

  validation {
    error_message = "Prefix must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([A-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix))
  }
}

variable "region" {
  description = "Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions."
  type        = string
  default     = "us-south"
}

variable "resource_group" {
  description = "Name of existing resource group where all infrastructure will be provisioned"
  type        = string
  default     = "asset-development"

  validation {
    error_message = "Unique ID must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.resource_group))
  }
}

variable "tags" {
  description = "List of tags to apply to resources created by this module."
  type        = list(string)
  default     = ["ez-vpc", "multizone-vpc"]
}

##############################################################################


##############################################################################
# VPC Variables
##############################################################################

variable "use_public_gateways" {
  description = "Add a public gateway in each zone."
  type        = bool
  default     = true
}

variable "allow_inbound_traffic" {
  description = "Add a rule to the ACL to allow for inbound traffic from any IP address."
  type        = bool
  default     = true
}

variable "classic_access" {
  description = "Add the ability to access classic infrastructure from your VPC."
  type        = bool
  default     = false
}

##############################################################################


##############################################################################
# Cluster Variables
##############################################################################

variable "zones" {
  description = "Number of zones for the cluster"
  type        = number
  default     = 3

  validation {
    error_message = "There must be at least one worker in each zone."
    condition     = var.zones > 0 && var.zones < 4
  }
}

variable "iks_cluster_version" {
  description = "IKS Cluster version. To get a list of valid versions, use the IBM Cloud CLI command `ibmcloud ks versions`. To use the default version, leave as `default`."
  type        = string
  default     = "default"
}

variable "machine_type" {
  description = "The flavor of VPC worker node to use for your cluster. Use `ibmcloud ks flavors` to find flavors for a region."
  type        = string
  default     = "bx2.4x16"
}

variable "workers_per_zone" {
  description = "Number of workers to provision in each subnet"
  type        = number
  default     = 1

  validation {
    error_message = "There must be at least one worker in each zone."
    condition     = var.workers_per_zone > 0
  }
}

variable "disable_public_service_endpoint" {
  description = "Disable public service endpoint for cluster. Once the service endpoint has been enabled, it cannot be disabled after cluster creation."
  type        = bool
  default     = true
}

variable "wait_till" {
  description = "To avoid long wait times when you run your Terraform code, you can specify the stage when you want Terraform to mark the cluster resource creation as completed. Depending on what stage you choose, the cluster creation might not be fully completed and continues to run in the background. However, your Terraform code can continue to run without waiting for the cluster to be fully created. Supported args are `MasterNodeReady`, `OneWorkerNodeReady`, and `IngressReady`"
  type        = string
  default     = "IngressReady"

  validation {
    error_message = "`wait_till` value must be one of `MasterNodeReady`, `OneWorkerNodeReady`, or `IngressReady`."
    condition = contains([
      "MasterNodeReady",
      "OneWorkerNodeReady",
      "IngressReady"
    ], var.wait_till)
  }
}

##############################################################################


##############################################################################
# Override Variables
##############################################################################

variable "override" {
  description = "Override default values with custom JSON template. This uses the file `override.json` to allow users to create a fully customized environment."
  type        = bool
  default     = false
}

##############################################################################