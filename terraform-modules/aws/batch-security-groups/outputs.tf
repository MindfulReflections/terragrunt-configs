output "security_group_ids" {
  description = "Map of created SG IDs by identifier"
  value       = { for key, sg in module.batch-security-group : key => sg.security_group_id }
}