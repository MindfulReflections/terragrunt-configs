# Terragrunt Usage for `batch-ec2` Terraform Module

This configuration provisions one or more EC2 instances with flexible settings. SSH public keys are loaded automatically from files and injected via user-data into each instance. The module supports public or private subnets and is integrated with reusable Terragrunt patterns.

---

## Directory Structure

```
terragrunt-configs/
├── common_vars/
│   └── general.hcl
├── prod/
│   └── aws/
│       └── computing/
│           └── 01-prefect/
│               ├── terragrunt.hcl
│               └── keys/
│                   └── id_ed25519.pub
```

---

## Example 1: EC2 in a public subnet with dynamic SSH key injection

```hcl
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
  ssh_pub_keys  = [for f in local.ssh_key_files : file("${local.ssh_dir}/${f}")]

  tags = merge(
    include.general.locals.env.tags,
    local.env_vars.tags,
    { TerraformStateKey = "${path_relative_to_include("root")}/terraform.tfstate" }
  )
}

inputs = {
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

  ssh_public_keys = local.ssh_pub_keys
  tags            = local.tags

  instances = {
    one = {
      create_eip  = false
      volume_tags = local.tags
    }
  }
}
```

---

## Example 2: EC2 in a private subnet with static key

```hcl
inputs = {
  name_prefix   = "backend-${local.env_vars.env}"
  subnets       = dependency.vpc.outputs.private_subnets
  instance_type = "t3.medium"

  common_security_group_ids = [
    dependency.security-groups-base.outputs.security_group_ids["internal"]
  ]

  ssh_public_keys = [
    "ssh-ed25519 AAAAC3Nza... user@example"
  ]

  root_block_device = [{
    volume_size = 16
  }]

  tags = local.tags

  instances = {
    worker = {
      create_eip  = false
      volume_tags = local.tags
    }
  }
}
```

---

## Features

- Create multiple EC2 instances via `instances` map
- Inject multiple SSH public keys from `*.pub` files or inline
- Automatically generate user-data from template
- Support for public/private subnets and tags

---

## Inputs

| Name                       | Description                              | Type           | Required |
|----------------------------|------------------------------------------|----------------|----------|
| `name_prefix`              | Prefix for instance names and tags       | `string`       | ✅       |
| `subnets`                  | List of subnet IDs                       | `list(string)` | ✅       |
| `instance_type`            | EC2 instance type                        | `string`       | ✅       |
| `ssh_public_keys`          | List of SSH public keys (strings)        | `list(string)` | ✅       |
| `tags`                     | Common resource tags                     | `map(string)`  | ✅       |
| `common_security_group_ids`| Security groups for all instances        | `list(string)` | ✅       |
| `instances`                | Instance configurations map              | `map(object)`  | ✅       |
| `root_block_device`        | Root EBS config                          | `list(object)` | ❌       |

---

## Outputs

| Name                                | Description                          |
|-------------------------------------|--------------------------------------|
| `instance_ids`                      | Map of instance names to EC2 IDs     |
| `instance_public_ips`              | Map of instance names to public IPs  |
| `instance_private_ips`             | Map of instance names to private IPs |
| `instance_arns`                    | Map of instance names to ARNs        |
| `instance_root_block_device_info`  | Root volume info                     |

---

## Requirements

- Terraform 1.3+
- Terragrunt 0.45+
- AWS CLI configured
- EC2 key files in `${layer}/keys/*.pub`

---

## Quick Start

```bash
cd terragrunt-configs/prod/aws/computing/01-prefect
terragrunt apply
```

---

## Cleanup

```bash
terragrunt destroy
```

---

## Author

Developed and maintained by **Aliaksei Shybeka** for **MindfulReflections Project**.
