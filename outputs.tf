output "ec2-ip" {
  value = aws_instance.minimal-instance.public_ip
  description = "My instance's ip"
}