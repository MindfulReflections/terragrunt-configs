# If no AZs provided, fetch all available zones in this region
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  selected_azs = length(var.azs) > 0 ? var.azs : data.aws_availability_zones.available.names

}

module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "5.19.0"
  cidr                 = var.vpc_cidr
  azs                  = local.selected_azs
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_nat_gateway   = var.enable_nat_gateway
  enable_vpn_gateway   = var.enable_vpn_gateway

  tags = var.tags

  name = var.name
  public_subnet_suffix   = var.public_subnet_suffix
  private_subnet_suffix  = var.private_subnet_suffix
}
