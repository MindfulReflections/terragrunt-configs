# Include root configuration with remote state and global settings
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Include shared environment-level variables and common tags
include "general" {
  path   = "${dirname(find_in_parent_folders("root.hcl"))}/common_vars/general.hcl"
  expose = true
}

# Declare dependency on VPC module to obtain VPC ID
dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "mock-vpc-output"
  }
}

# Define the source of the Terraform module
terraform {
  source = "../../../../terraform-modules/aws/batch-security-groups"
}

# Local values for environment variables and merged tagging strategy
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

# Module input variables for batch-security-groups
inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id
  tags   = local.tags

  security_groups = {
    ssh = {
      name        = "ssh"
      description = "Allow SSH access from admin and internal networks"
      ingress = [
        {
          from_port   = "22"
          to_port     = "22"
          protocol    = "tcp"
          cidr_blocks = ["192.168.100.0/24", "10.8.8.0/24", "94.43.14.179/32"]
        }
      ]
      egress = [
        {
          from_port   = "0"
          to_port     = "0"
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }

    web = {
      name        = "web"
      description = "Allow public inbound HTTP and HTTPS access"
      ingress = [
        {
          from_port   = "80"
          to_port     = "80"
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          from_port   = "443"
          to_port     = "443"
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      egress = []
    }

    internal = {
      name        = "internal"
      description = "Allow all internal VPC traffic"
      ingress = [
        {
          from_port   = "0"
          to_port     = "0"
          protocol    = "-1"
          cidr_blocks = ["10.0.0.0/8"]
        }
      ]
      egress = [
        {
          from_port   = "0"
          to_port     = "0"
          protocol    = "-1"
          cidr_blocks = ["10.0.0.0/8"]
        }
      ]
    }
  }
}
