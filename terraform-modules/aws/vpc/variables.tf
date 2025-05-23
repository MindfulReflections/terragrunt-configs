# Input variables for VPC and subnet provisioning

# Base name used for tagging resources
variable "name" {
  type        = string
  description = "Base name used to prefix resource names (e.g. production, dev)"
  default     = "private"
}

# CIDR block for the entire VPC
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

# List of availability zones to deploy subnets into
variable "azs" {
  description = "Availability Zones to use"
  type        = list(string)
}

# Public subnet CIDR blocks
variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

# Private subnet CIDR blocks
variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

# DNS-related flags
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

# Enable or disable NAT gateway
variable "enable_nat_gateway" {
  type    = bool
  default = false
}

# Enable or disable VPN gateway
variable "enable_vpn_gateway" {
  type    = bool
  default = false
}

# Global resource tags
variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Suffix for naming public subnets
variable "public_subnet_suffix" {
  type        = string
  description = "Suffix for public subnets (e.g. 'public' → name-public-1, name-public-2)"
  default     = "public"
}

# Suffix for naming private subnets
variable "private_subnet_suffix" {
  type        = string
  description = "Suffix for private subnets (e.g. 'private' → name-private-1, name-private-2)"
  default     = "private"
}

variable "map_public_ip_on_launch" {
  description = "Whether to enable auto-assign public IP on public subnets"
  type        = bool
  default     = true
}