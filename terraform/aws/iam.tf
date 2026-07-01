# Usamos el LabRole que AWS Academy ya provee, en vez de crear uno nuevo
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}
