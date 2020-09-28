resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.public1.id, aws_subnet.public2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_parameter_group" "mysql8" {
  name   = "rds-pg"
  family = "mysql8.0"

  tags = {
    Name = var.project_name
  }
}

resource "aws_security_group" "default" {
  name   = "rds_sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "MySQL"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.project_name
  }
}

resource "aws_db_instance" "db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0.20"
  instance_class       = "db.t2.micro"
  name                 = "embulk_test"
  username             = "dbuser"
  password             = "password"
  parameter_group_name = aws_db_parameter_group.mysql8.name

  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.default.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name

  skip_final_snapshot = true

  tags = {
    Name = var.project_name
  }
}
