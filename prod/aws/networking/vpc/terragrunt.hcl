include "root" {
  path = find_in_parent_folders()
}

include "general" {
  path   = "${dirname(find_in_parent_folders())}/common_vars/general.hcl"
  expose = true
}

terraform {
  source = "../../../../terraform-modules/aws/vpc"
}

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals

  tags = merge(
    include.general.locals.env.tags,
    local.environment_vars.tags,
    {
      TerraformStateKey = "${path_relative_to_include("root")}/terraform.tfstate"
    }
  )
}

inputs = {
  vpc_cidr        = local.environment_vars.vpc_cidr
  azs             = ["eu-central-1a", "eu-central-1b"]
  public_subnets  = ["10.20.1.0/24", "10.20.2.0/24"]
  private_subnets = ["10.20.11.0/24", "10.20.12.0/24"]

  map_public_ip_on_launch = true

  enable_nat_gateway = false
  single_nat_gateway = false
  enable_vpn_gateway = false

  enable_dns_support   = true
  enable_dns_hostnames = true


  tags = local.tags

  name = local.environment_vars.env
  public_subnet_suffix  = "public"
  private_subnet_suffix = "private"
}
