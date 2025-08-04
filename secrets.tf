

# ----------------- Terraform: Create SSH key -----------------
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "public"
  public_key = tls_private_key.private_key.public_key_openssh
}

# ----------------- AWS Secrets Manager: Key Storage -----------------
resource "aws_secretsmanager_secret" "ssh_private_key" {
  name        = "ssh_private_key"
  description = "Private key for SSH access to EC2 instance"
}
resource "aws_secretsmanager_secret_version" "ssh_private_key_version" {
  secret_id     = aws_secretsmanager_secret.ssh_private_key.id
  secret_string = tls_private_key.private_key.private_key_pem
}