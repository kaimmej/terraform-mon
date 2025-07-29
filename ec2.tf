

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

  # render user data from a template file
  user_data                   = templatefile("user-data.sh", {
    server_port = var.server_port
    db_username = "my_user"
    db_password = "my_password"
  })
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
