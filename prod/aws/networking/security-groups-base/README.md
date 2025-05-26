# Terragrunt Usage for `aws/batch-security-groups` Terraform Module

This document describes how to use the `terraform-modules/aws/batch-security-groups` module with Terragrunt. It provides configuration examples for setting up reusable security groups within an existing VPC. The module is designed for production-grade environments, supporting internal access control, SSH ingress, and public web traffic exposure.

## Structure Overview

The security groups configuration should follow the same Terragrunt project layout, promoting separation of environments and consistency across modules:

```
terragrunt-configs/
├── common_vars/
│   └── general.hcl
├── prod/
│   └── aws/
│       └── networking/
│           ├── vpc/
│           │   └── terragrunt.hcl
│           └── security-groups-base/
│               └── terragrunt.hcl
```

---

## Example: Base security groups for production VPC

```hcl
terraform {
  source = "../../../../terraform-modules/aws/batch-security-groups"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "general" {
  path   = "${dirname(find_in_parent_folders("root.hcl"))}/common_vars/general.hcl"
  expose = true
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "vpc-123456"
  }
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
```

---

## Notes

- All security group names and descriptions should follow internal naming conventions.
- SSH ingress should always be restricted to known admin or VPN CIDRs.
- The `web` group intentionally allows public access. Ensure that only necessary services are exposed.
- Use the `internal` group for internal-only traffic (e.g., between ECS services or databases).
- Tagging is centralized using `general.hcl` and `env.hcl`, ensuring consistency across modules.

## Author

Developed and maintained by **Aliaksei Shybeka** for **MindfulReflections Project**.