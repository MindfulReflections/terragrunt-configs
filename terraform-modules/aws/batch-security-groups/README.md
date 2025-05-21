
# Terraform Module: Batch Security Groups

This Terraform module allows you to declaratively define and provision multiple AWS Security Groups with flexible ingress and egress rules. It is designed to be used in Terragrunt-based infrastructures and provides a simple interface for bulk security group management.

## Features

- Create multiple security groups using a structured input map
- Support for both ingress and egress rules per security group
- Tags support for all resources
- Flexible protocol/port/CIDR configurations

## Module Structure

- `main.tf`: Core logic for security group creation
- `variables.tf`: Module input variables
- `outputs.tf`: Module outputs

## Inputs

| Name                    | Description                                 | Type   | Required |
|-------------------------|---------------------------------------------|--------|----------|
| `security_groups`       | Map of security group definitions           | map(any) | yes      |
| `vpc_id`                | The VPC ID where SGs will be created        | string | yes      |
| `tags`                  | Common tags to apply to all SGs             | map(string) | no  |

Each `security_group` in the map may include:
```hcl
{
  description = "Description of the SG"
  ingress = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
```

## Outputs

| Name               | Description                                     |
|--------------------|-------------------------------------------------|
| `security_group_ids` | Map of security group names to their AWS IDs |

## Example Usage (Terragrunt)

### Basic

```hcl
terraform {
  source = "../../../../terraform-modules/aws/batch-security-groups"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../../networking/vpc"
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id

  security_groups = {
    ssh = {
      description = "Allow SSH"
      ingress = [
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }

    internal = {
      description = "Internal SG"
      ingress = [
        {
          from_port   = 0
          to_port     = 65535
          protocol    = "tcp"
          cidr_blocks = ["10.0.0.0/8"]
        }
      ]
      egress = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }

  tags = {
    Project   = "Example"
    ManagedBy = "Terragrunt"
  }
}
```

## Best Practices

- Use descriptive names and tags to identify SG purposes.
- Minimize CIDR ranges for security (avoid 0.0.0.0/0 in production).
- Use this module in combination with VPC and compute modules for full automation.

##  Author

Developed and maintained by **Aliaksei Shybeka** for **MindfulReflections Project**.