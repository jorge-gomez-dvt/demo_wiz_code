resource "aws_iam_user" "deploy_user" {
  name = "deploy-bot"
  path = "/"

  # Access keys stored in Terraform state
}

resource "aws_iam_access_key" "deploy_key" {
  user = aws_iam_user.deploy_user.name
}

# Overly permissive policy
resource "aws_iam_policy" "deploy_policy" {
  name = "deploy-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"          # Full admin access
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "deploy_attach" {
  user       = aws_iam_user.deploy_user.name
  policy_arn = aws_iam_policy.deploy_policy.arn
}

# IAM role with trust policy open to all AWS accounts
resource "aws_iam_role" "cross_account_role" {
  name = "cross-account-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = "*" }  # Any AWS account can assume this role!
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# MFA not enforced on admin users
resource "aws_iam_group" "admins" {
  name = "admins"
}

resource "aws_iam_group_policy_attachment" "admin_attach" {
  group      = aws_iam_group.admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  # No MFA condition
}
