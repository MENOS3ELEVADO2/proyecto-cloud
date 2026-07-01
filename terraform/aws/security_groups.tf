# --- Security Group para el ALB (público) ---
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Permite trafico HTTP/HTTPS desde internet hacia el ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP desde internet"
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

  tags = {
    Name = "alb-sg"
  }
}

# --- Security Group para ECS Fargate (privado) ---
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg"
  description = "Permite trafico solo desde el ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Frontend desde ALB"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_sg.id]
  }

  ingress {
    description     = "Backend desde ALB"
    from_port        = 8000
    to_port          = 8000
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-sg"
  }
}

# --- Security Group para RDS (privado estricto) ---
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Permite trafico solo desde ECS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL desde ECS"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups  = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}