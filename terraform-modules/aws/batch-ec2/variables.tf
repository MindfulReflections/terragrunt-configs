variable "name_prefix" {
  description = "Prefix for EC2 instance names and Name tag"
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs to distribute instances across (used round-robin if no subnet_id provided)"
  type        = list(string)
}

variable "instances" {
  description = "Map of EC2 instances with optional per-instance overrides"
  type = map(object({
    subnet_id         = optional(string) # Force the instance into a specific subnet if provided
    availability_zone = optional(string) # Override the availability zone if provided
    ami               = optional(string) # Override the AMI per instance
    create_eip        = optional(bool)   # Allocate an Elastic IP if true

    extra_ebs_volumes = optional(list(object({ # Additional EBS volumes per instance
      device_name = string                     # EBS device name, e.g. "/dev/xvdh"
      mount_point = string                     # Intended mount path inside the instance, e.g. "/data"
      type        = string                     # EBS volume type, e.g. "gp3"
      size        = number                     # Volume size in GiB
    })))                                       # The mount_point is for documentation; mounting must be handled in user_data

    ssh_key_name = optional(string)      # Override the SSH key name per instance
    volume_tags  = optional(map(string)) # Tags for additional EBS volumes and Elastic IP
  }))
}

variable "common_security_group_ids" {
  description = "Security groups to associate with all EC2 instances"
  type        = list(string)
  default     = []
}

variable "extra_security_groups_inline" {
  description = "Optional inline security groups to be created within this module"
  type        = map(any)
  default     = {}
  # NOTE: This variable is declared but not used; remove it or implement SG creation logic.
}

variable "instance_type" {
  description = "Default EC2 instance type, e.g. t3.micro"
  type        = string
  default     = "t3.micro"
}

variable "create_spot_instance" {
  description = "Launch instances as Spot instances if true"
  type        = bool
  default     = false
}

variable "spot_type" {
  description = "Spot instance request type (one-time or persistent)"
  type        = string
  default     = "one-time"
}

variable "spot_instance_interruption_behavior" {
  description = "Behavior when a Spot instance is interrupted (terminate, stop, or hibernate)"
  type        = string
  default     = "terminate"
}

variable "associate_public_ip_address" {
  description = "Associate a public IP address with the instance if true"
  type        = bool
  default     = false
}

variable "root_block_device" {
  description = "Root block device configuration (type, size, etc.)"
  type        = any
  default = [{
    volume_type = "gp3"
    volume_size = 30
  }]


}

variable "ebs_block_device" {
  description = "Default additional EBS block device definition"
  type        = any
  default     = null
}

variable "ssh_key_name" {
  description = "Default SSH key pair name to use"
  type        = string
  default     = null
}

variable "user_data" {
  description = "Default user data script (shell script or cloud-init)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "ami_ssm_parameter" {
  description = "SSM parameter name for default AMI; set to \"\" to disable SSM lookup"
  type        = string
  default     = ""
}

variable "ssh_public_keys" {
  description = "List of SSH public keys to install on each instance"
  type        = list(string)
  default     = []
}