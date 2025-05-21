variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "Availability Zones to use"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}
variable "enable_nat_gateway" {
  type    = bool
  default = false
}

variable "enable_vpn_gateway" {
  type    = bool
  default = false
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames for the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS resolution support for the VPC"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}


variable "public_subnet_suffix" {
  type        = string
  description = "Suffix for public subnets (e.g. 'public' → name-public-1, name-public-2)"
  default     = "public"
}

variable "private_subnet_suffix" {
  type        = string
  description = "Suffix for private subnets (e.g. 'private' → name-private-1, name-private-2)"
  default     = "private"
}

variable "name" {
  type        = string
  description = "base name"
  default     = "private"
}
