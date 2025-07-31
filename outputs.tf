output "ec2-ip" {
  value       = aws_instance.minimal-instance.public_ip
  description = "My instance's ip"
}

output "load_balancer_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}
