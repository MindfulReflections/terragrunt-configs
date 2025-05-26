# Read all subnets that we will distribute instances across
data "aws_subnet" "selected" {
  for_each = toset(var.subnets)
  id       = each.key
}

locals {
  # Render user-data из шаблона, подставляя ssh_public_keys
  user_data = templatefile("${path.module}/templates/user_data.tpl", {
    ssh_keys = var.ssh_public_keys
  })

  # Stable ordering of instance keys
  sorted_instance_keys = sort(keys(var.instances))

  # List of subnet IDs & map ID → AZ
  subnet_ids        = [for s in data.aws_subnet.selected : s.id]
  subnet_az_mapping = {
    for s in data.aws_subnet.selected :
    s.id => s.availability_zone
  }

  # Determine which subnet each instance should use (round‐robin if not overridden)
  instance_subnets = {
    for idx, name in local.sorted_instance_keys :
    name => (
      var.instances[name].subnet_id != null ?
      var.instances[name].subnet_id :
      local.subnet_ids[idx % length(local.subnet_ids)]
    )
  }

  # Resolve subnet and AZ placement per instance
  instance_placement = {
    for name, subnet_id in local.instance_subnets :
    name => {
      subnet_id         = subnet_id
      availability_zone = (
        var.instances[name].availability_zone != null ?
        var.instances[name].availability_zone :
        local.subnet_az_mapping[subnet_id]
      )
    }
  }

  # Filter instances that require an Elastic IP
  instances_with_eip = {
    for name, cfg in var.instances :
    name => cfg if try(cfg.create_eip, false)
  }

  # Build per-instance list of EBS volumes
  instance_volumes = {
    for name, cfg in var.instances :
    name => (
      cfg.extra_ebs_volumes != null ? cfg.extra_ebs_volumes :
      var.ebs_block_device != null ? [var.ebs_block_device] : []
    )
  }
}

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.7.0"

  for_each = var.instances

  # Name and tags for the instance
  name = "${var.name_prefix}-${each.key}"
  tags = var.tags

  # AMI and instance type
  instance_type = var.instance_type

  # Networking
  subnet_id              = local.instance_placement[each.key].subnet_id
  availability_zone      = local.instance_placement[each.key].availability_zone
  vpc_security_group_ids = var.common_security_group_ids

  associate_public_ip_address = (
    contains(keys(each.value), "associate_public_ip_address") ?
    each.value.associate_public_ip_address :
    null
  )

  # Spot settings
  create_spot_instance                = var.create_spot_instance
  spot_type                           = var.spot_type
  spot_instance_interruption_behavior = var.spot_instance_interruption_behavior

  # Root volume
  root_block_device = var.root_block_device

  # Additional EBS volumes
  ebs_block_device = [
    for vol in local.instance_volumes[each.key] : {
      device_name = vol.device_name
      volume_type = vol.type
      volume_size = vol.size
    }
  ]

  # SSH and user data
  # key_name  = try(each.value.ssh_key_name, var.ssh_key_name)
  user_data = local.user_data
}

resource "aws_eip" "this" {
  for_each = local.instances_with_eip

  instance = module.ec2[each.key].id
  tags     = try(each.value.volume_tags, var.tags)
}
