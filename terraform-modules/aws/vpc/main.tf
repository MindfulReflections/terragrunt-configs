module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "5.19.0"
  cidr                 = var.vpc_cidr
  azs                  = var.azs
  public_subnets       = var.public_subnets
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_nat_gateway   = var.enable_nat_gateway
  enable_vpn_gateway   = var.enable_vpn_gateway

  tags = merge(
    var.tags,
    {
      Name = "${var.tags.Environment}-${var.vpc_cidr}-VPC"
    }
  )
}
