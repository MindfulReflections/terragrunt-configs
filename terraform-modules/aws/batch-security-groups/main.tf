terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

module "batch-security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  for_each = var.security_groups

  name        = each.value.name
  description = each.value.description
  vpc_id      = var.vpc_id

  # Преобразуем ingress → list(map(string))
  ingress_with_cidr_blocks = [
    for rule in each.value.ingress : {
      from_port   = tostring(rule.from_port)
      to_port     = tostring(rule.to_port)
      protocol    = rule.protocol
      cidr_blocks = join(",", rule.cidr_blocks)
    }
  ]

  # То же для egress
  egress_with_cidr_blocks = [
    for rule in each.value.egress : {
      from_port   = tostring(rule.from_port)
      to_port     = tostring(rule.to_port)
      protocol    = rule.protocol
      cidr_blocks = join(",", rule.cidr_blocks)
    }
  ]

  tags = var.tags
}
