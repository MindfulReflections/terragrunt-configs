include "root"{
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../terraform-modules/aws/vpc"
}

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  tags = merge(
    local.environment_vars.tags,
    { TerraformStateKey = "${path_relative_to_include()}/terraform.tfstate" }
  )
}

inputs = {
  vpc_cidr                = local.environment_vars.vpc_cidr
  azs                     = ["eu-central-1a", "eu-central-1b"]
  public_subnets          = ["10.10.1.0/24", "10.10.2.0/24"]
  map_public_ip_on_launch = true
  enable_nat_gateway      = false
  enable_vpn_gateway      = false
  single_nat_gateway      = false

  tags = local.tags
}
