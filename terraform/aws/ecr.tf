resource "aws_ecr_repository" "frontend" {
  name                 = "proyecto-cloud-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "frontend-ecr"
  }
}

resource "aws_ecr_repository" "backend" {
  name                 = "proyecto-cloud-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "backend-ecr"
  }
}