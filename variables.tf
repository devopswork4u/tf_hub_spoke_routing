
variable "enable_linux_vm" {
  type        = bool
  description = "Controls the deployment of the linux vm"
  default     = false
}

variable "enable_windows_vm" {
  type        = bool
  description = "Controls the deployment of the linux vm"
  default     = true
}

variable "enable_sqlmi" {
  type        = bool
  description = "Controls the deployment of the linux vm"
  default     = false
}

variable "vm_size" {}
variable "admin_username" {}
variable "admin_password" {}


variable "global_details" {
  type = map(object
    ({
      name          = string
      location      = string
      address_space = string
      subnet        = string
      subnet_type   = string
  }))
}

variable "environment" {
  description = "Environment: dev, test, prod"
  default     = "dev"
}

variable "instance_number" {
  description = "Instance Number: 001, 002, ..., 998, 999"
  default     = "001"
}

locals {
  common_tags = {
    Environment = "${var.environment}"
    Owner       = "Rahul Sharma"
    CostCenter  = "1234"
  }
}



variable "location" {
  default = "eastus"
}
variable "secondary_location" {
  default = "westus2"
}
variable "admin_user" {
  default = "adminuser"
}
variable "login_password" {
  default = "7p0m5App@1234567"
}
variable "sku_name" {
  default = "GP_Gen5"
}

variable "azure_short_location" {}

variable "subscription_id" {
  type = string
}