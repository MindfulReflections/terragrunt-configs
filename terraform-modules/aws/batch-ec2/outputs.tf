# Map of instance keys to EC2 instance IDs
output "instance_ids" {
  description = "Map of each instance key to its EC2 instance ID"
  value       = { for key, inst in module.ec2 : key => inst.id }
}

# Map of instance keys to EC2 instance ARNs
output "instance_arns" {
  description = "Map of each instance key to its EC2 instance ARN"
  value       = { for key, inst in module.ec2 : key => inst.arn }
}

# Map of instance keys to private IPv4 addresses
output "instance_private_ips" {
  description = "Map of each instance key to its private IPv4 address"
  value       = { for key, inst in module.ec2 : key => inst.private_ip }
}

# Map of instance keys to public IPv4 addresses (if associated)
output "instance_public_ips" {
  description = "Map of each instance key to its public IPv4 address, if one was assigned"
  value       = { for key, inst in module.ec2 : key => inst.public_ip }
}

# Map of instance keys to the subnet IDs where they were launched
output "instance_subnet_ids" {
  description = "Map of each instance key to the subnet ID where it was launched"
  value       = { for key, placement in local.instance_placement : key => placement.subnet_id }
}

# Map of instance keys to the availability zones where they were launched
output "instance_availability_zones" {
  description = "Map of each instance key to its availability zone"
  value       = { for key, placement in local.instance_placement : key => placement.availability_zone }
}

# Map of instance keys to primary network interface IDs
output "instance_primary_network_interface_ids" {
  description = "Map of each instance key to its primary network interface ID"
  value       = { for key, inst in module.ec2 : key => inst.primary_network_interface_id }
}

# Map of instance keys to additional EBS block device information
output "instance_ebs_block_device_info" {
  description = "Map of each instance key to the list of additional EBS block devices as returned by the module"
  value       = { for key, inst in module.ec2 : key => inst.ebs_block_device }
}

# Map of instance keys to root block device information
output "instance_root_block_device_info" {
  description = "Map of each instance key to its root block device information"
  value       = { for key, inst in module.ec2 : key => inst.root_block_device }
}

# Map of instance keys to Elastic IP addresses (for instances with create_eip = true)
output "instance_eip_addresses" {
  description = "Map of each instance key to its allocated Elastic IP address, for instances where create_eip was enabled"
  value       = { for key, e in aws_eip.this : key => e.public_ip }
}

# Map of instance keys to Elastic IP allocation IDs
output "instance_eip_allocation_ids" {
  description = "Map of each instance key to its Elastic IP allocation ID, for instances where create_eip was enabled"
  value       = { for key, e in aws_eip.this : key => e.allocation_id }
}


output "subnets" {
  description = "Subnets used for EC2 placement"
  value       = var.subnets
}