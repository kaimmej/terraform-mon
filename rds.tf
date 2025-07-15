

resource "aws_security_group" "rds" {
  name   = "rds-allow-ec2"
  vpc_id = data.aws_vpc.default.id
}

resource "random_password" "master-user" {
  length  = 16
  special = false
}


resource "aws_secretsmanager_secret" "rds-mu" {
  name = "postgres-master-user"
}

resource "aws_secretsmanager_secret_version" "rds-mu" {
  secret_id = aws_secretsmanager_secret.rds-mu.id
  secret_string = random_password.master-user.result
}


resource "aws_vpc_security_group_ingress_rule" "postgres-port" {
  security_group_id = aws_security_group.rds.id
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
  cidr_ipv4         = data.aws_vpc.default.cidr_block
}
resource "aws_vpc_security_group_egress_rule" "postgres-outbound" {
  security_group_id = aws_security_group.rds.id
  ip_protocol       = -1
  cidr_ipv4         = "0.0.0.0/0"
}


resource "aws_rds_cluster" "rds" {
  cluster_identifier     = "aurora-cluster"
  engine             = "aurora-postgresql"
  engine_mode        = "provisioned"
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true
  master_username        = "master"
  master_password        = random_password.master-user.result

  serverlessv2_scaling_configuration {
    max_capacity             = 1.0
    min_capacity             = 0.0
    seconds_until_auto_pause = 3600
  }
}

resource "aws_rds_cluster_instance" "example" {
  cluster_identifier = aws_rds_cluster.rds.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.rds.engine
  engine_version     = aws_rds_cluster.rds.engine_version
}