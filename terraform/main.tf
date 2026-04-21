# Configure AWS provider
provider "aws" {
  region = "us-east-1"
}

# ---------------------------
# 1. VPC (Network)
# ---------------------------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "mpesa-vpc"
  }
}

# ---------------------------
# 2. Subnets
# ---------------------------

# Public subnet (for  the app)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# Private subnet (for the database)
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private-subnet"
  }
}

# ---------------------------
# 3. Security Group
# ---------------------------
resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.main.id

  # Allow HTTP traffic (for  the app)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------
# 4. Compute (EC2)
# ---------------------------
resource "aws_instance" "app_server" {
  ami           = "ami-0c55b159cbfafe1f0" # placeholder AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name = "mpesa-app-server"
  }
}
# In production, this password would be retrieved from AWS Secrets Manager
# ---------------------------
# 5. Database (RDS - PostgreSQL)
# ---------------------------
resource "aws_db_instance" "db" {
  allocated_storage = 20
  engine            = "postgres"
  instance_class    = "db.t3.micro"

  db_name  = "payments_db"
  username = "admin"

  # ⚠️ Placeholder only
  password = "examplepassword"

  skip_final_snapshot = true

  # Ideally placed in private subnet
  # (simplified here for clarity)

  tags = {
    Name = "mpesa-db"
  }
}

# ---------------------------
# 6. Secrets (Concept Only)
# ---------------------------

# In production:
# - Passwords would NOT be hardcoded
# - They would be stored in AWS Secrets Manager
# - The app would fetch them securely at runtime