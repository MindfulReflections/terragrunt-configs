data "aws_ami" "amazon_linux_23" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

module "ec2_multi_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.7.0"

  for_each = var.instances

  name          = "${var.name}-${each.key}"
  ami           = lookup(each.value, "ami", data.aws_ami.amazon_linux_23.id)
  iam_role_name = try(var.iam_role_name, null)
  instance_type = lookup(each.value, "instance_type", var.default_instance_type)


  availability_zone = lookup(each.value, "az", null)
  subnet_id         = lookup(each.value, "subnet_id", null)


  vpc_security_group_ids = compact(
    distinct(
      concat(
        var.common_security_group_ids,
        try(lookup(each.value, "security_group_ids", []), [])
      )
    )
  )


  associate_public_ip_address = lookup(each.value, "associate_public_ip_address", (var.associate_public_ip_address || lookup(each.value, "create_eip", false)))
  root_block_device           = lookup(each.value, "root_block_device", var.default_root_block_device)
  ebs_block_device            = lookup(each.value, "ebs_block_device", var.default_ebs_block_device)
  create_eip                  = lookup(each.value, "create_eip", false)
  key_name                    = var.default_key_name

  create_spot_instance                = lookup(each.value, "create_spot_instance", var.default_create_spot_instance)
  spot_type                           = lookup(each.value, "spot_type", var.default_spot_type)
  spot_instance_interruption_behavior = lookup(each.value, "spot_instance_interruption_behavior", var.default_spot_instance_interruption_behavior)

  user_data = templatefile("${path.module}/templates/user_data.tpl", {
    node_exporter_install = var.default_node_exporter_install
    default_user_data     = var.default_user_data
    instance_user_data    = lookup(each.value, "user_data", "")
    ssh_keys              = var.ssh_keys
  })

  eip_tags = {
    Name = "${var.name}-${each.key}"
  }

  tags = var.tags
}