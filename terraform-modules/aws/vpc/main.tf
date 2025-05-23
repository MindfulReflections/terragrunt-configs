# Fetch available AZs (fallback if none given)
data "aws_availability_zones" "available" {
  state = "available"
}

# Local variables
locals {
  # Use provided AZs or fallback to all available in the region
  selected_azs = length(var.azs) > 0 ? var.azs : data.aws_availability_zones.available.names
}

# VPC Module Configuration
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  # Networking configuration
  cidr            = var.vpc_cidr
  azs             = local.selected_azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  map_public_ip_on_launch = var.map_public_ip_on_launch

  # Feature flags
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_nat_gateway   = var.enable_nat_gateway
  enable_vpn_gateway   = var.enable_vpn_gateway

  # Tags and naming
  name                   = var.name
  tags                   = var.tags
  public_subnet_suffix   = var.public_subnet_suffix
  private_subnet_suffix  = var.private_subnet_suffix
}
