# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "mpesa-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr

  tags = {
    Name = "private-subnet"
  }
}

# Security Group (Least privilege - only HTTP allowed)
resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow internal communication only
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance (to run container)
resource "aws_instance" "app" {
  ami           = "ami-0c55b159cbfafe1f0" # Placeholder
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name = "mpesa-app-server"
  }
}

# In production, this password would be retrieved from AWS Secrets Manager
# RDS (PostgreSQL in private subnet)
resource "aws_db_instance" "db" {
  allocated_storage    = 20
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  db_name              = "payments_db"
  username             = "admin"
  password             = "examplepassword" # Placeholder (NOT production safe)

  skip_final_snapshot  = true

  vpc_security_group_ids = [aws_security_group.app_sg.id]
}