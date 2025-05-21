variable "vpc_id" {
  description = "VPC ID where SGs will be created"
  type        = string
}

variable "tags" {
  description = "Map of tags to apply to all SGs"
  type        = map(string)
  default     = {}
}

variable "security_groups" {
  description = <<EOF
Map of security group definitions. Key is group identifier, value object with:
 - name        : SG name
 - description : SG description
 - ingress     : list of ingress rules (each object matches module input)
 - egress      : list of egress rules (each object matches module input)
EOF
  type = map(object({
    name        = string
    description = string
    ingress = optional(list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = optional(list(string), [])
    })), [])
    egress = optional(list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = optional(list(string), [])
    })), [])
  }))
}
