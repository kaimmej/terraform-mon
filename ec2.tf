

data "aws_vpc" "default" {
  default = true
}

resource "aws_key_pair" "public_Jon" {
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCkI8MhSUcuCGQymb1cTzGwLs37biKFRB70h5WQkvesoS5mKXyAK3h4uPIThRxhI5Ehw5WJ++kCTBuMN0z3BJmXTQmZgxOPiORjUJULe9ELI4rZxoLsgBtY8ytaReI/P9jGHsKkPx2ebmwF7E+rZ6JHdOGRNLl0N7lc/XxOpOzxRPfDSfnydDoD9e+J+q3xh6DMD1gKGH2A3YrAl697lNm9BpmCkpSoAONE5nfjzbqn3KYjNF3ITQPZ/1XcJtAmWgwckLMa1yQdjoLUS3zpHSJc0ABCMf8IUQIJ/DDD2yIusqeoe4RGne1s3x64RlrPdBEB0NoGx4f5CmsSOeEiIHF1"
}
resource "aws_key_pair" "public_Ben" {
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOwp+5sSt53+244HeH6l1ZCM+jsEX3woB+K8Noi1eenZ"
}

resource "aws_iam_instance_profile" "ec2-role" {
  name = aws_iam_role.ec2-role.name
  role = aws_iam_role.ec2-role.name
}


resource "aws_instance" "minimal-instance" {
  ami                         = "ami-0738bc713c45160fd"
  instance_type               = "t4g.small"
  key_name                    = aws_key_pair.public_Jon.key_name
  vpc_security_group_ids      = [aws_security_group.open.id]
  user_data_replace_on_change = true
  iam_instance_profile        = aws_iam_role.ec2-role.name
  user_data                   = <<EOF
#!/bin/bash

# 
# Adding Ben's public key to the instance. 
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOwp+5sSt53+244HeH6l1ZCM+jsEX3woB+K8Noi1eenZ" >> /home/ec2-user/.ssh/authorized_keys

# 
# DOCKER
service docker start
export PG_PASSWORD=$(aws secretsmanager get-secret-value --secret-id postgres-master-user --query SecretString)
# docker run -d -p 80:80 -e PG_PASSWORD=$${PG_PASSWORD} -e PG_USER=master nginx

# 
# NGINX
# Write the nginx.conf file to the instance
# This configuration sets up NGINX to reverse proxy requests to the Django application.
cat << 'NGINXCONF' > /home/ec2-user/nginx.conf
events {}

http {
    server {
        listen 80;

        location / {
            proxy_pass http://app:8000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}
NGINXCONF

# 
# DOCKER COMPOSE
# Write the docker-compose file to the instance
cat << 'COMPOSE' > /home/ec2-user/docker-compose-dockermon.yml
name: dockermon
version: '3.8'
services :


  # Django application service.
  # Gunicorn is used as the WSGI server.
  app:
    build:
      context: ./parentProject-dockermon
      dockerfile: Dockerfile
    image: kaimmej/django_dockermon:latest
    container_name: docker-container-pokedex
    command: "gunicorn dockermon.wsgi:application --bind 0.0.0.0:8000 --workers 3"
    ports:
      - "8000:8000"

  db:
    image: postgres:latest
    container_name: postgres-db
    environment:
      POSTGRES_USER: my_user
      POSTGRES_PASSWORD: my_password
      POSTGRES_DB: my_database
    ports:
      - "5432:5432"
  
  # NGINX reverse proxy setup.
  nginx:
    image: nginx:latest
    container_name: nginx-proxy
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - app

COMPOSE

# RUN DOCKER-COMPOSE
docker-compose -f /home/ec2-user/docker-compose-dockermon.yml up -d

EOF
}

resource "aws_security_group" "open" {
  name        = "ec2-open-ssh"
  description = "open to the world"
  vpc_id      = data.aws_vpc.default.id
}



resource "aws_vpc_security_group_ingress_rule" "open-ssh" {
  security_group_id = aws_security_group.open.id

  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "nginx-port" {
  security_group_id = aws_security_group.open.id

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "outbound-open" {
  security_group_id = aws_security_group.open.id
  ip_protocol       = -1
  cidr_ipv4         = "0.0.0.0/0"
}
