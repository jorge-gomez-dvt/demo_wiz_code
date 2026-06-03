# Intentionally misconfigured Terraform for demo purposes

provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}

# S3 bucket publicly accessible
resource "aws_s3_bucket" "data_bucket" {
  bucket = "company-sensitive-data"
  acl    = "public-read-write"

  tags = {
    Environment = "production"
  }
}

# S3 bucket without encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.data_bucket.id
  # No encryption configured
}

# Security group with all ports open
resource "aws_security_group" "wide_open" {
  name        = "allow_all"
  description = "Allow all traffic"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH open to the world
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # RDP open to the world
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance with public IP and no key pair
resource "aws_instance" "web" {
  ami                         = "ami-0c55b159cbfafe1f0"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.wide_open.id]

  # User data with hardcoded credentials
  user_data = <<-EOF
    #!/bin/bash
    export DB_PASSWORD=SuperSecret123!
    export API_KEY=sk-prod-xxxxxxxxxxx
    echo "DB_PASS=password123" >> /etc/environment
  EOF

  # No encrypted root volume
  root_block_device {
    encrypted = false
  }
}

# RDS without encryption
resource "aws_db_instance" "default" {
  identifier           = "prod-database"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.6.41"  # Old version
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "admin"
  password             = "password123"  # Hardcoded password
  publicly_accessible  = true           # DB exposed to internet
  storage_encrypted    = false
  deletion_protection  = false
  skip_final_snapshot  = true

  # No backup
  backup_retention_period = 0
}

# IAM policy with admin access
resource "aws_iam_policy" "admin_policy" {
  name = "full-admin-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      }
    ]
  })
}

# Lambda with sensitive env vars
resource "aws_lambda_function" "api_function" {
  filename      = "lambda.zip"
  function_name = "api-handler"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs12.x"  # EOL runtime

  environment {
    variables = {
      DB_PASSWORD     = "SuperSecret123!"
      JWT_SECRET      = "hardcoded_jwt_secret"
      AWS_ACCESS_KEY  = "AKIAIOSFODNN7EXAMPLE"
      STRIPE_KEY      = "sk_live_DEMO_FAKE_KEY_FOR_WIZ_SCAN"
    }
  }
}

# KMS key without rotation
resource "aws_kms_key" "main" {
  description             = "Main KMS key"
  enable_key_rotation     = false  # Rotation disabled
  deletion_window_in_days = 7
}

# CloudTrail without log file validation
resource "aws_cloudtrail" "main" {
  name                          = "main-trail"
  s3_bucket_name                = aws_s3_bucket.data_bucket.id
  include_global_service_events = false
  enable_log_file_validation    = false  # No integrity check
  is_multi_region_trail         = false
}
