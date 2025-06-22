output "address" {
  description = "The instance IP"
  value       = aws_instance.web.private_dns
}
