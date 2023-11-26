
# Application Load Balancer
resource "aws_lb" "arthur_alb" {
  name               = "arthur-lb-asg"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.arthur_sg_for_alb.id]
  subnets            = [aws_subnet.arthur_public_subnet1.id, aws_subnet.arthur_public_subnet2.id]
}

resource "aws_lb_target_group" "arthur_alb_tg" {
  name     = "arthur-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.arthur_main_vpc.id

  # Configuração de Health Checks
  health_check {
    enabled             = true
    interval            = 30
    path                = "/healthcheck"  
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    matcher             = "200"
  }
}

resource "aws_lb_listener" "arthur_alb_listener" {
  load_balancer_arn = aws_lb.arthur_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.arthur_alb_tg.arn
  }
}