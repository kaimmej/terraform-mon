output "ec2-ip" {
  value       = aws_instance.minimal-instance.public_ip
  description = "My instance's ip"
}

output "docker-image-name" {
  value       = aws_ecs_task_definition.my_task_definition.container_definitions[0].image
  description = "The Docker image name that the EC2 container will pull down"
}