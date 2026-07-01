# --- KMS Key para cifrado del bucket ---
resource "aws_kms_key" "s3_key" {
  description             = "Llave KMS para cifrar el bucket de Proyecto Cloud"
  deletion_window_in_days = 7

  tags = {
    Name = "proyecto-cloud-kms"
  }
}

resource "aws_kms_alias" "s3_key_alias" {
  name          = "alias/proyecto-cloud-s3"
  target_key_id = aws_kms_key.s3_key.key_id
}

# --- Bucket S3 ---
resource "aws_s3_bucket" "main" {
  bucket = "proyecto-cloud-datos-864846952757"

  tags = {
    Name = "proyecto-cloud-bucket"
  }
}

# --- Cifrado del bucket con KMS ---
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_key.arn
    }
  }
}

# --- Bloquear acceso publico (seguridad) ---
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls       = true
  restrict_public_buckets  = true
}

# --- Versionado (proteccion contra borrados accidentales) ---
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}