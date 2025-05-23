# Terraform Module: VPC

This Terraform module provisions an AWS Virtual Private Cloud (VPC) with both public and private subnets across specified Availability Zones (AZs). It leverages the official AWS VPC module by [terraform-aws-modules](https://github.com/terraform-aws-modules/terraform-aws-vpc), adding customizable subnet naming conventions and flexible tagging.

---

##  Features

- **Automated VPC creation** with configurable CIDR block.
- **Dynamic subnet provisioning** across multiple AZs.
- **Customizable naming conventions** for public/private subnets.
- **Comprehensive tagging** for easy resource management and identification.
- **DNS support configuration** (hostnames and DNS resolution).
- **Optional NAT/VPN gateway creation**.

---

##  Module Usage

### Basic Example

```hcl
module "vpc" {
  source  = "path-to-your-module/aws/vpc"

  name             = "production"
  vpc_cidr         = "10.20.0.0/16"
  azs              = ["eu-central-1a", "eu-central-1b"]
  public_subnets   = ["10.20.1.0/24", "10.20.2.0/24"]
  private_subnets  = ["10.20.11.0/24", "10.20.12.0/24"]

  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_nat_gateway   = false
  enable_vpn_gateway   = false

  tags = {
    Environment = "production"
    Project     = "MindfulReflections"
    ManagedBy   = "Terragrunt"
    Owner       = "DevOps"
  }

  public_subnet_suffix  = "public"
  private_subnet_suffix = "private"
}
```

---

##  Inputs

| Name                     | Description                                | Type           | Default         | Required |
|--------------------------|--------------------------------------------|----------------|-----------------|----------|
| `name`                   | Prefix for resource names                   | `string`       | `"private"`     | no       |
| `vpc_cidr`               | CIDR block for the VPC                      | `string`       | n/a             | yes      |
| `azs`                    | Availability zones to use                   | `list(string)` | n/a             | yes      |
| `public_subnets`         | Public subnet CIDR blocks                   | `list(string)` | n/a             | yes      |
| `private_subnets`        | Private subnet CIDR blocks                  | `list(string)` | n/a             | yes      |
| `enable_dns_support`     | Enable DNS support for VPC                  | `bool`         | `true`          | no       |
| `enable_dns_hostnames`   | Enable DNS hostnames in VPC                 | `bool`         | `true`          | no       |
| `enable_nat_gateway`     | Enable NAT gateway creation                 | `bool`         | `false`         | no       |
| `enable_vpn_gateway`     | Enable VPN gateway creation                 | `bool`         | `false`         | no       |
| `tags`                   | Tags to apply to all resources              | `map(string)`  | `{}`            | no       |
| `public_subnet_suffix`   | Suffix for naming public subnets            | `string`       | `"public"`      | no       |
| `private_subnet_suffix`  | Suffix for naming private subnets           | `string`       | `"private"`     | no       |

---

##  Outputs

| Name              | Description                           |
|-------------------|---------------------------------------|
| `vpc_id`          | The ID of the created VPC             |
| `vpc_cidr`        | The CIDR block of the created VPC     |
| `vpc_arn`         | The ARN of the created VPC            |
| `public_subnets`  | List of IDs of public subnets         |
| `private_subnets` | List of IDs of private subnets        |

---

##  Requirements

| Name        | Version   |
|-------------|-----------|
| Terraform   | >= 1.0.0  |
| AWS provider| >= 4.0.0  |

---

##  Quick Start

Initialize Terraform modules and providers:

```bash
terraform init
```

Review and validate your changes:

```bash
terraform plan
```

Apply to create resources:

```bash
terraform apply
```

---

##  Cleanup

To remove created resources:

```bash
terraform destroy
```

---

##  Author

Developed and maintained by **Aliaksei Shybeka** for **MindfulReflections Project**.

---

📌 *Ensure you customize input variables according to your infrastructure's specifics.*
