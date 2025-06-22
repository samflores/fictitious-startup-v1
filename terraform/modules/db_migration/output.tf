output "address" {
  description = "The replicator instance IP"
  value       = element(aws_dms_replication_instance.bootcamp_dms_instance.replication_instance_private_ips, 0)
}
