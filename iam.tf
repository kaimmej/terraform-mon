resource "aws_iam_role" "ec2-role" {
  name               = "mon-ec2-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# resource "aws_iam_role_policy" "get-db-password" {
#   name = "get-db-password"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "secretsmanager:Get*"
#         ]
#         Effect   = "Allow"
#         Resource = aws_secretsmanager_secret.rds-mu.arn
#       },
#     ]
#   })
#   role = aws_iam_role.ec2-role.id
# }


