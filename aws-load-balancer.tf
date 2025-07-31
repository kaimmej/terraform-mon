# ----------------- IAM -----------------





# ----------------- AWS Load Balancer Controller (Ingress) -----------------
resource "aws_lb" "main" {
  name               = "application-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]

  # Reference the public subnets in the VPC
  subnets = [
    aws_subnet.public_subnet_a.id,
    aws_subnet.public_subnet_b.id
  ]

  enable_deletion_protection = false
}


resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.main.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.app.arn
    }
}

# Description: Add a listener rule that sends requests that match ANY PATH to the target group. Which is the EC2 instance by default. 
resource "aws_lb_listener_rule" "app" {
    listener_arn = aws_lb_listener.http.arn
    priority     = 100
    
    condition {
        path_pattern {
            values = ["*"]
        }
    }
    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.app.arn
    }
}

# Decription: This target group will health check the EC2 instance on the root path ("/") 
resource "aws_lb_target_group" "app" {
  name     = "app-target-group"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# ----------------- Load Balancer Security Groups -----------------
resource "aws_security_group" "lb_sg" {
  name        = "lb-sg"
  description = "Security group for the load balancer"
  vpc_id      = aws_vpc.main.id

  # Allow inbound HTTP traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}