

data "aws_vpc" "default" {
  default = true
}

resource "aws_key_pair" "public" {
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOwp+5sSt53+244HeH6l1ZCM+jsEX3woB+K8Noi1eenZ"
}

resource "aws_iam_instance_profile" "ec2-role" {
  name = aws_iam_role.ec2-role.name
  role = aws_iam_role.ec2-role.name
}


resource "aws_instance" "minimal-instance" {
  ami                         = "ami-094440448bb7e69f6"
  instance_type               = "t4g.small"
  key_name                    = aws_key_pair.public.key_name
  vpc_security_group_ids      = [aws_security_group.open.id]
  user_data_replace_on_change = true
  iam_instance_profile = aws_iam_role.ec2-role.name
  user_data                   = <<EOF
#!/bin/bash
service docker start
export PG_PASSWORD=$(aws secretsmanager get-secret-value --secret-id postgres-master-user --query SecretString)
docker run -d -p 80:80 -e PG_PASSWORD=$${PG_PASSWORD} -e PG_USER=master nginx

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
