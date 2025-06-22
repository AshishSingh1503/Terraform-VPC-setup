provider "aws" {
  region = "us-west-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "172.20.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.20.1.0/24"
  availability_zone       = "us-west-1a"
  map_public_ip_on_launch = true
  tags = { Name = "pub-sub-1" }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.20.2.0/24"
  availability_zone       = "us-west-1b"
  map_public_ip_on_launch = true
  tags = { Name = "pub-sub-2" }
}

# Private Subnets
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.20.3.0/24"
  availability_zone = "us-west-1a"
  tags = { Name = "priv-sub-1" }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.20.4.0/24"
  availability_zone = "us-west-1b"
  tags = { Name = "priv-sub-2" }
}

# Elastic IPs for NAT
resource "aws_eip" "nat_a" {
  vpc = true
}
resource "aws_eip" "nat_b" {
  vpc = true
}

# NAT Gateways
resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_a.id
  depends_on    = [aws_internet_gateway.igw]
  tags = { Name = "nat-gateway-a" }
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.public_b.id
  depends_on    = [aws_internet_gateway.igw]
  tags = { Name = "nat-gateway-b" }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "public-rt" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_a.id
  }
  tags = { Name = "private-rt" }
}

# Route Table Associations
resource "aws_route_table_association" "pub_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "pub_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "priv_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "priv_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

# Security Groups
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow SSH from my IP"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_PUBLIC_IP/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami                    = "ami-0fc5d935ebf8bc3bc"  # Amazon Linux 2 (us-west-1)
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_b.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = "your-key-name"
  associate_public_ip_address = true
  tags = { Name = "bastion-host" }
}

# Add EC2 app instances and Load Balancer here if needed...

