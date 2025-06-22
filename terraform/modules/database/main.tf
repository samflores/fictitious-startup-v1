resource "aws_db_instance" "database" {
  allocated_storage = 5
  engine            = "postgres"
  engine_version    = "16.3"
  instance_class    = "db.t3.micro"
  username          = var.username
  password          = var.password
  db_name           = var.db_name

  db_subnet_group_name   = aws_db_subnet_group.database_sng.name
  parameter_group_name   = aws_db_parameter_group.pg_parameter_group.name
  vpc_security_group_ids = [aws_security_group.database_sg.id]
  apply_immediately      = true
  skip_final_snapshot    = true
}

resource "aws_db_subnet_group" "database_sng" {
  name       = var.subnet_group_name
  subnet_ids = var.subnet_ids

  tags = {
    Name = "DB subnet group"
  }
}

resource "aws_db_parameter_group" "pg_parameter_group" {
  family = "postgres16"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }

}

resource "aws_security_group" "database_sg" {
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "database_sg_ingress" {
  security_group_id = aws_security_group.database_sg.id
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "database_sg_egress" {
  security_group_id = aws_security_group.database_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
