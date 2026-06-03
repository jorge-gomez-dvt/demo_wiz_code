resource "aws_s3_bucket" "logs" {
  bucket = "company-access-logs"
  acl    = "public-read"  # Logs publicly readable!

  # No versioning
  # No lifecycle policy
  # No encryption
}

resource "aws_s3_bucket" "backups" {
  bucket = "company-db-backups"
  acl    = "public-read-write"  # Backups writable by anyone!
}

resource "aws_s3_bucket" "static" {
  bucket = "company-static-assets"
  acl    = "public-read"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "PUT", "DELETE"]
    allowed_origins = ["*"]  # CORS open to all
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_policy" "data_policy" {
  bucket = aws_s3_bucket.logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"       # Anyone can access
        Action    = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource  = "${aws_s3_bucket.logs.arn}/*"
      }
    ]
  })
}
