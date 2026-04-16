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

resource "aws_instance" "web" {
  ami = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"

  key_name = aws_key_pair.deployer.key_name

  security_groups = [aws_security_group.web_sg.name]

    user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd

              systemctl start httpd
              systemctl enable httpd

              echo "<h1>Projeto AWS com Terraform</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "web-server"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "aws-key"
  public_key = file("../aws-key.pub")
}

output "public_ip" {
  value = aws_instance.web.public_ip
}