terraform {
  source = "../../../../terraform-modules/aws/batch-ec2"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "general" {
  path   = "${dirname(find_in_parent_folders("root.hcl"))}/common_vars/general.hcl"
  expose = true
}

dependency "vpc" {
  config_path = "../../networking/vpc"

  mock_outputs = {
    public_subnets = [
      "10.20.1.0/24",
      "10.20.2.0/24"
    ]
  }
}

dependency "security-groups-base" {
  config_path = "../../networking/security-groups-base"

  mock_outputs = {
    security_group_ids = {
      ssh      = "sg-00000000000000001"
      internal = "sg-00000000000000002"
    }
  }
}

locals {
  env_vars       = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  ssh_dir        = "${get_terragrunt_dir()}/keys"
  ssh_key_files  = fileset(local.ssh_dir, "*.pub")
  ssh_pub_keys   = [
    for f in local.ssh_key_files : file("${local.ssh_dir}/${f}")
  ]
  tags = merge(
    include.general.locals.env.tags,
    local.env_vars.tags,
    {
      TerraformStateKey = "${path_relative_to_include("root")}/terraform.tfstate"
    }
  )
}

inputs = {
  name_prefix               = "prefect-${local.env_vars.env}"
  subnets                   = dependency.vpc.outputs.public_subnets
  instance_type             = "t2.micro"
  common_security_group_ids = [
    dependency.security-groups-base.outputs.security_group_ids["ssh"],
    dependency.security-groups-base.outputs.security_group_ids["internal"]
  ]
  root_block_device = [
    {
      volume_size = 8
    }
  ]
  ssh_public_keys = local.ssh_pub_keys
  tags            = local.tags

  instances = {
    one = {
      create_eip  = false
      volume_tags = include.general.locals.env.tags
    }
  }
}
