# Terragrunt Usage for `aws/vpc` Terraform Module

This document explains how to use the `terraform-modules/aws/vpc` module with Terragrunt. It provides configuration examples for different environments and use cases, including production, development, and testing scenarios.

## Structure Overview

Terragrunt encourages reusability and DRY (Don't Repeat Yourself) principles. Your project directory might look like this:

```
terragrunt-configs/
├── common_vars/
│   └── general.hcl
├── prod/
│   └── aws/
│       └── networking/
│           └── vpc/
│               └── terragrunt.hcl
├── dev/
│   └── aws/
│       └── networking/
│           └── vpc/
│               └── terragrunt.hcl
```

---

## Example 1: Basic VPC with public and private subnets

```hcl
terraform {
  source = "../../../../terraform-modules/aws/vpc"
}

include "root" {
  path = find_in_parent_folders()
}

include "general" {
  path   = "${dirname(find_in_parent_folders())}/common_vars/general.hcl"
  expose = true
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
  vpc_cidr              = "10.10.0.0/16"
  azs                   = ["eu-central-1a", "eu-central-1b"]
  public_subnets        = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnets       = ["10.10.11.0/24", "10.10.12.0/24"]
  map_public_ip_on_launch = true

  enable_nat_gateway    = false
  enable_vpn_gateway    = false
  enable_dns_support    = true
  enable_dns_hostnames  = true

  tags = local.tags
}
```

---

## Example 2: Minimal VPC for internal workloads (no public subnets)

```hcl
inputs = {
  vpc_cidr              = "10.20.0.0/16"
  azs                   = ["eu-central-1a", "eu-central-1b"]
  public_subnets        = []
  private_subnets       = ["10.20.11.0/24", "10.20.12.0/24"]

  enable_nat_gateway    = false
  enable_vpn_gateway    = false
  enable_dns_support    = true
  enable_dns_hostnames  = true

  tags = {
    Project = "InternalOnly"
    Owner   = "NetworkingTeam"
    Env     = "staging"
  }
}
```

---

## Example 3: Production-ready VPC with NAT gateway

```hcl
inputs = {
  vpc_cidr              = "10.30.0.0/16"
  azs                   = ["eu-central-1a", "eu-central-1b"]
  public_subnets        = ["10.30.1.0/24", "10.30.2.0/24"]
  private_subnets       = ["10.30.11.0/24", "10.30.12.0/24"]

  map_public_ip_on_launch = true
  enable_nat_gateway    = true
  single_nat_gateway    = true
  enable_vpn_gateway    = true
  enable_dns_support    = true
  enable_dns_hostnames  = true

  tags = {
    Project = "CustomerApp"
    Owner   = "DevOps"
    Env     = "production"
  }
}
```

---

## Notes

- The `tags` block should always include common metadata like `Environment`, `Project`, and `Owner`.
- NAT Gateway costs are non-trivial. Use `enable_nat_gateway = false` for cost-saving environments.
- Availability Zones (`azs`) can be dynamically fetched, but explicit declaration ensures predictable subnet mapping.

##  Author

Developed and maintained by **Aliaksei Shybeka** for **MindfulReflections Project**.
