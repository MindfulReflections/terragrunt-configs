variable "name" {
  type    = string
  default = null
}

variable "instances" {
  type    = any
  default = {}
}

variable "iam_role_name" {
  type    = string
  default = null
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "subnets" {
  type    = list(string)
  default = null
}

variable "common_security_group_ids" {
  type        = list(string)
  default     = []
  description = "Security groups applied to all EC2 instances in the batch. Combined with instance-specific groups (if any)."
}

variable "default_instance_type" {
  type    = string
  default = ""
}

variable "extra_security_group" {
  type    = any
  default = {}
}

variable "ssh_keys" {
  type    = list(string)
  default = []
}

variable "default_key_name" {
  type    = string
  default = null
}

variable "associate_public_ip_address" {
  type    = bool
  default = false
}

variable "default_root_block_device" {
  type    = any
  default = []
}

variable "default_ebs_block_device" {
  type    = any
  default = []
}

variable "default_user_data" {
  type    = string
  default = ""
}

variable "default_node_exporter_install" {
  type    = bool
  default = true
}

##############
# EXTRA EBS
##############

variable "default_extra_ebs_volume_type" {
  type    = string
  default = null
}

variable "default_extra_ebs_volume_size" {
  type    = number
  default = null
}

variable "default_extra_ebs_volume_throughput" {
  type    = number
  default = null
}

variable "default_extra_ebs_volume_iops" {
  type    = number
  default = null
}

variable "default_extra_ebs_device_name" {
  type    = string
  default = "/dev/sdh"
}

variable "default_create_spot_instance" {
  description = "Default value for whether to create Spot Instances"
  type        = bool
  default     = false
}

variable "default_spot_type" {
  description = "Default Spot Instance type (one-time or persistent)"
  type        = string
  default     = "persistent"
}

variable "default_spot_instance_interruption_behavior" {
  description = "Default Spot Instance interruption behavior"
  type        = string
  default     = "stop"
}

variable "tags" {
  type    = map(string)
  default = {}
}