# Define provider (AWS)
provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIA6GBMHHHGAMUE3XNV"
  secret_key = "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"
}

# Create an S3 bucket
resource "aws_s3_bucket" "	s3-ak-bucket" {
  bucket = "	s3-ak-bucket"
}

# Create an IAM Role for EC2 instance
resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach a policy to the IAM Role to allow access to S3
resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Create a bucket policy for allowing GetObject
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.bucket
  policy = jsonencode({
    Id       = "Policy1711920929569",
    Version  = "2012-10-17",
    Statement = [
      {
        Sid       = "Stmt1711920907274",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "arn:aws:s3:::s3-ak-bucket/*"
      }
    ]
  })
}

# Launch Configuration for Auto Scaling Group
resource "aws_launch_configuration" "web_lc" {
  name               = "web_lc"
  image_id           = "ami-007020fd9c84e18c7" 
  instance_type      = "t2.micro"
  security_groups    = ["default"]   
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = ["sg-0123456789abcdef0"]  # Replace with your actual security group IDs
  vpc_classic_link_security_group_ids = ["sg-0123456789abcdef0"]  # Replace with your actual security group IDs

  lifecycle {
    create_before_destroy = true
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install docker -y
              service docker start
              echo "Hello, World!" > index.html
              aws s3 cp index.html s3://${aws_s3_bucket.my_bucket.bucket}/index.html
              export AWS_ACCESS_KEY_ID="${var.access_key}"
              export AWS_SECRET_ACCESS_KEY="${var.secret_key}"
              export S3_BUCKET_NAME="${aws_s3_bucket.my_bucket.bucket}"
              export AWS_REGION="${var.region}"
              EOF
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web_asg" {
  name                  = "web_asg"
  launch_configuration = aws_launch_configuration.web_lc.name
  min_size              = 1
  max_size              = 3
  desired_capacity      = 1
  vpc_zone_identifier   = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]  # Replace with your actual subnet IDs
}
