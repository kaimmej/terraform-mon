

data "aws_vpc" "default" {
  default = true
}

resource "aws_key_pair" "public" {
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOwp+5sSt53+244HeH6l1ZCM+jsEX3woB+K8Noi1eenZ"
}
resource "aws_instance" "minimal-instance" {
  ami                    = "ami-0d70ce345c8086fe8"
  instance_type          = "t4g.small"
  key_name               = aws_key_pair.public.key_name
  vpc_security_group_ids = [aws_security_group.open.id]
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