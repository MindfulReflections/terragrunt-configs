# Terraform Module: Batch EC2

This Terraform module provisions multiple EC2 instances across one or more subnets, dynamically injecting SSH public keys via user data templates. It is optimized for use with **Terragrunt** and supports batch configuration, Elastic IP attachment, and consistent tagging.

## Features

- Launch multiple EC2 instances with dynamic names
- Inject multiple SSH public keys via user data template
- Tag root volumes and support additional EBS volumes
- Configure EIP attachment per instance
- Select subnets and availability zones flexibly

## Module Structure

- `main.tf`: Core EC2 provisioning logic with looping
- `variables.tf`: Input definitions
- `outputs.tf`: Output maps for instance attributes
- `user_data.tpl`: Cloud-init template for SSH key injection

---

## Requirements

| Name      | Version       |
|-----------|---------------|
| Terraform | >= 1.3.0      |
| AWS       | >= 4.0        |

---

## Inputs

| Name                   | Description                                         | Type           | Required |
|------------------------|-----------------------------------------------------|----------------|----------|
| `name_prefix`          | Prefix for instance names and tags                  | `string`       | yes      |
| `subnets`              | List of subnet IDs to distribute instances across   | `list(string)` | yes      |
| `instance_type`        | EC2 instance type (e.g., `t3.micro`)                | `string`       | yes      |
| `ssh_public_keys`      | List of public SSH keys to inject                   | `list(string)` | yes      |
| `common_security_group_ids` | List of security group IDs applied to all instances | `list(string)` | yes      |
| `instances`            | Map of instance keys to custom settings             | `map(object)`  | yes      |
| `tags`                 | Map of tags to apply                                | `map(string)`  | no       |
| `root_block_device`    | Block device configuration for root volume          | `list(object)` | yes      |
| `create_spot_instance` | Whether to use Spot instances                       | `bool`         | no       |

---

## Outputs

| Name                                 | Description                                 |
|--------------------------------------|---------------------------------------------|
| `instance_ids`                       | Map of instance keys to EC2 IDs             |
| `instance_arns`                      | Map of instance keys to ARNs                |
| `instance_public_ips`               | Public IPs (if available)                   |
| `instance_private_ips`              | Private IPs                                 |
| `instance_subnet_ids`               | Assigned subnets                            |
| `instance_availability_zones`      | Assigned availability zones                 |
| `instance_root_block_device_info`  | Root volume info                            |
| `instance_ebs_block_device_info`   | Additional EBS volumes                      |
| `instance_primary_network_interface_ids` | Primary network interface IDs         |
| `instance_eip_addresses`           | Elastic IPs                                 |
| `instance_eip_allocation_ids`      | EIP allocation IDs                          |

---

## Example Usage (Terragrunt)

### Public EC2 Instances with SSH Keys

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
  ssh_public_keys = local.ssh_pub_keys
  common_security_group_ids = [
    dependency.security-groups-base.outputs.security_group_ids["ssh"],
    dependency.security-groups-base.outputs.security_group_ids["internal"]
  ]
  root_block_device = [{ volume_size = 8 }]
  tags = local.tags

  instances = {
    one = {
      create_eip   = false
      volume_tags  = local.tags
    }
  }
}
```

### Private EC2 Instances (No Public IP)

Set `associate_public_ip_address = false` in `instances.one`.

---

## Quick Start

```bash
cd terragrunt-configs/prod/aws/computing/01-prefect
terragrunt init
terragrunt apply
```

## Cleanup

```bash
terragrunt destroy
```

---

## Author

Developed and maintained by **Aliaksei Shybeka** for **MindfulReflections Project**.