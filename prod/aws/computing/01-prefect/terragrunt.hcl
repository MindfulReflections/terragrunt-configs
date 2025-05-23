terraform {
  source = "../../../../terraform-modules/aws/batch-ec2"
}

include "root" {
  path = find_in_parent_folders()
}

include "general" {
  path   = "${dirname(find_in_parent_folders())}/common_vars/general.hcl"
  expose = true
}

dependency "vpc" {
  config_path = "../../networking/vpc"
}

dependency "security-groups-base" {
  config_path = "../../networking/security-groups-base"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals

  ssh_dir       = "${get_terragrunt_dir()}/keys"
  ssh_key_files = fileset(local.ssh_dir, "*.pub")

  ssh_pub_keys = [
    for f in local.ssh_key_files :
    file("${local.ssh_dir}/${f}")
  ]

  # Common tags for all resources
  tags = merge(
    include.general.locals.env.tags,
    local.env_vars.tags,
    { TerraformStateKey = "${path_relative_to_include("root")}/terraform.tfstate" }
  )
}

inputs = {
  # Module inputs
  name_prefix   = "prefect-${local.env_vars.env}"
  subnets       = dependency.vpc.outputs.public_subnets
  instance_type = "t2.micro"

  common_security_group_ids = [
    dependency.security-groups-base.outputs.security_group_ids["ssh"],
    dependency.security-groups-base.outputs.security_group_ids["internal"]
  ]
  root_block_device = [{
    volume_size = 8
  }]
  # ssh_key_name = include.general.locals.env.ssh_keys[0] # pick your default SSH key
  ssh_public_keys = local.ssh_pub_keys

  tags = local.tags

  instances = {
    one = {
      # override AMI, allocate EIP, attach extra volumes, tag them

      create_eip = false

      volume_tags = include.general.locals.env.tags
      # ssh_key_name можно переопределить и здесь, если нужно
    }
  }
}
