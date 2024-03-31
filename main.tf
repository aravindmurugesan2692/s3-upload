# Define provider (AWS)
provider "aws" {
  region     = "ap-south-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

# Create an S3 bucket
resource "aws_s3_bucket" "s3_ak_bucket" {
  bucket = "s3-ak-bucket"
}

# Create an IAM Role for EC2 instance
resource "aws_iam_role" "ec2_role" {
  name = "s3-ak-bucket"
  
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
  policy_arn = "arn:aws:s3:::s3-ak-bucket"
}

# Create a load balancer security group
resource "aws_security_group" "akloadbalancer" {
  name        = "akloadbalancer"
  description = "Allow inbound traffic to load balancer"

  ingress {
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
}

# Create an Application Load Balancer
resource "aws_lb" "akloadbalancer" {
  name               = "akloadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"] 
}

# Create a Target Group
resource "aws_lb_target_group" "ak_target_group" {
  name     = "ak_target_group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "vpc-0c4a85522f1516ba8" 

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "8080"
    protocol            = "HTTP"
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Associate Target Group with Load Balancer Listener
resource "aws_lb_listener" "ak_target_group_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ak_target_group.arn
  }
}

# Launch Configuration for Auto Scaling Group
resource "aws_launch_configuration" "autoscaling" {
  name               = "autoscaling"
  image_id           = "ami-007020fd9c84e18c7" 
  instance_type      = "t2.micro"
  security_groups    = ["default"]   
  iam_instance_profile = aws_iam_role.ec2_role.name
  vpc_security_group_ids = ["sg-0123456789abcdef0"]  
  vpc_classic_link_security_group_ids = ["sg-0123456789abcdef0"] 

  lifecycle {
    create_before_destroy = true
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install docker -y
              service docker start
              echo "Hello, World!" > index.html
              aws s3 cp index.html s3://${aws_s3_bucket.s3_ak_bucket.bucket}/index.html
              export AWS_ACCESS_KEY_ID="${var.access_key}"
              export AWS_SECRET_ACCESS_KEY="${var.secret_key}"
              export S3_BUCKET_NAME="${aws_s3_bucket.s3_ak_bucket.bucket}"
              export AWS_REGION="${var.region}"
              EOF
}

# Auto Scaling Group
resource "aws_autoscaling_group" "autoscaling" {
  name                  = "autoscaling"
  launch_configuration = aws_launch_configuration.web_lc.name
  min_size              = 1
  max_size              = 3
  desired_capacity      = 1
  target_group_arns     = [aws_lb_target_group.ak_target_group.arn] 
}
