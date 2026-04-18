resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP and SSH"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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

resource "aws_launch_template" "web" {
  name_prefix = "web-template"

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  image_id           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"

  key_name = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.web_sg.id]

user_data = base64encode(<<-EOF
#!/bin/bash

yum update -y
yum install -y httpd aws-cli

systemctl start httpd
systemctl enable httpd

cd /var/www/html
rm -rf *

aws s3 cp s3://${aws_s3_bucket.app_bucket.bucket}/index.html .

chown -R apache:apache /var/www/html

systemctl restart httpd
EOF
)

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "web-server"
    }
  }
}

resource "aws_autoscaling_group" "web" {
  name = "web-asg"
  
  desired_capacity = 2
  max_size         = 3
  min_size         = 2

  vpc_zone_identifier = [
    "subnet-0400bbfd37b893b96",
    "subnet-07b6241b1e86fc8b9"
  ]

  target_group_arns = [aws_lb_target_group.web_tg.arn]

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "web-server"
    propagate_at_launch = true
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "aws-key-ci"
  public_key = file("../aws-key-ci.pub")
}

resource "aws_lb_target_group" "web_tg" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-05d009c628bc9f7f4"

  health_check {
    path   = "/"
    port   = "traffic-port"
  }
}

resource "aws_lb" "web_alb" {
  name               = "web-alb"
  load_balancer_type = "application"
  subnets            = ["subnet-0400bbfd37b893b96", "subnet-07b6241b1e86fc8b9"]
  security_groups    = [aws_security_group.web_sg.id]
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn  = aws_lb.web_alb.arn
  port               = 80
  protocol           = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

resource "aws_cloudfront_distribution" "web_cdn" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  origin {
    domain_name = aws_lb.web_alb.dns_name
    origin_id   = "alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "allow-all"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "aws-project-training-${random_id.bucket_id.hex}"
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-s3-access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "ec2_policy" {
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = ["s3:GetObject"]
      Effect = "Allow"
      Resource = "${aws_s3_bucket.app_bucket.arn}/*"
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.web_cdn.domain_name
}

output "alb_dnv" {
  value = aws_lb.web_alb.dns_name
}

output "bucket_name" {
  value = aws_s3_bucket.app_bucket.bucket
}