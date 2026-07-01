# --- Application Load Balancer ---
resource "aws_lb" "main" {
  name               = "proyecto-cloud-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = {
    Name = "proyecto-cloud-alb"
  }
}

# --- Target Group para el Frontend ---
resource "aws_lb_target_group" "frontend" {
  name        = "frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name = "frontend-tg"
  }
}

# --- Target Group para el Backend ---
resource "aws_lb_target_group" "backend" {
  name        = "backend-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/api/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name = "backend-tg"
  }
}

# --- Listener: trafico HTTP entra al Frontend por default ---
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port               = 80
  protocol           = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# --- Regla: /api/* va al Backend ---
resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}