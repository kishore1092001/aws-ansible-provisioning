# Create EC2 Security Group
resource "aws_security_group" "web_sg" {
  name        = var.security_group_name
  description = "Allow HTTP and SSH access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

# Launch EC2 Instance
resource "aws_instance" "web_server" {
  ami             = var.ami_id
  instance_type   = var.ec2_instance_type
  key_name        = var.key_name
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name = "WebServer"
  }
}

# Create RDS Security Group
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow MySQL access from EC2"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create RDS MySQL Instance
resource "aws_db_instance" "mydb" {
  identifier            = var.db_instance_identifier
  engine               = "mysql"
  engine_version       = "8.0.35"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  username            = var.db_username
  password            = var.db_password
  publicly_accessible = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  skip_final_snapshot = true
}

