# ----------------- IAM -----------------





# ----------------- AWS Load Balancer Controller (Ingress) -----------------
# resource "aws_lb" "main" {
#   name               = "main-load-balancer"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.lb_sg.id]
#   subnets            = aws_subnet.public.*.id

#   enable_deletion_protection = false
# }


# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.main-load-balancer.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.app.arn
#   }
# }