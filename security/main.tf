provider "aws" {
  region = "us-east-2"
}

# IAM Role 
resource "aws_iam_role" "terraform_role" {
  name = "samy-terraform-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "terraform_policy" {
  name        = "terraform-policy"
  description = "Least privilege access for Terraform"
  policy      = file("terraform-policy.json")  
}

resource "aws_iam_role_policy_attachment" "terraform_attach" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.terraform_policy.arn
}

# Enable S3 Bucket Encryption for Terraform State
resource "aws_s3_bucket" "terraform_state" {
  bucket = "ivolvesamy-terraform-state-bucket"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
}
