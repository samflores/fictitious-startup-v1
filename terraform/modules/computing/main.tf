resource "aws_security_group" "instance_sg" {
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.instance_sg.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "postgres" {
  security_group_id = aws_security_group.instance_sg.id
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
  cidr_ipv4         = "${var.ip_allowed_to_access_db}/24"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.instance_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_instance" "web" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]
  iam_instance_profile        = length(var.instance_profile_names) > 0 ? var.instance_profile_names[0] : null

  tags = {
    Name = "WebServerInstance"
  }

  user_data = <<-EOF
              #!/bin/bash
              curl -O https://s3.amazonaws.com/amazon-ssm-us-east-2/latest/debian_amd64/amazon-ssm-agent.deb
              dpkg -i amazon-ssm-agent.deb
              systemctl enable amazon-ssm-agent
              systemctl start amazon-ssm-agent
              EOF
}

