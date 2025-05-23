# Include root configuration (defines remote state and global settings)
include "root" {
  path = find_in_parent_folders()
}

# Include general project-wide variables (e.g. common tags)
include "general" {
  path   = "${dirname(find_in_parent_folders())}/common_vars/general.hcl"
  expose = true
}

# Dependency on the VPC module
dependency "vpc" {
  config_path = "../vpc"
#   skip_outputs = true
#   mock_outputs = {
#   vpc_id = ""
#  }
}

# Use local module source
terraform {
  source = "../../../../terraform-modules/aws/batch-security-groups"
}

# Define common locals (environment vars and merged tags)
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

# Inputs passed to the batch-security-groups Terraform module
inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id
  # vpc_id = dependency.vpc.mock_outputs.vpc_id

  tags   = local.tags

  security_groups = {
    # Security group for SSH access from internal networks
    ssh = {
      name        = "ssh"
      description = "Allow SSH from internal admin network"
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

    # Public web access SG (HTTP/HTTPS)
    web = {
      name        = "web"
      description = "Public HTTP/HTTPS access"
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

    # Internal-only access SG (for private communication inside the VPC)
    internal = {
      name        = "internal"
      description = "Allow internal-only traffic"
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
