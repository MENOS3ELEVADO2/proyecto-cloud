# --- Subnet Group para RDS (usa las subredes privadas) ---
resource "aws_db_subnet_group" "main" {
  name       = "proyecto-cloud-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "proyecto-cloud-db-subnet-group"
  }
}

# --- Instancia RDS PostgreSQL Multi-AZ ---
resource "aws_db_instance" "main" {
  identifier     = "proyecto-cloud-db"
  engine         = "postgres"
  engine_version = "15.18"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = "proyectocloud"
  username = "postgres"
  password = "CambiaEstaClave123!"

  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  skip_final_snapshot = true
  publicly_accessible  = false

  tags = {
    Name = "proyecto-cloud-db"
  }
}