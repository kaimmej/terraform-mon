output "ec2-ip" {
  value       = aws_instance.minimal-instance.public_ip
  description = "My instance's ip"
}

output "load_balancer_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "https_certificate_arn" {
  description = "The ARN of the SSL/TLS certificate"
  value       = data.aws_acm_certificate.cert.arn
}
