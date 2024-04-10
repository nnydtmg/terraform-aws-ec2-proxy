# ---------------------------
# VPC
# ---------------------------
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true # DNSホスト名を有効化
  tags = {
    Name = "terraform-main-vpc"
  }
}

# ---------------------------
# Subnet
# ---------------------------
resource "aws_subnet" "main_public_sn" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = var.az_a

  tags = {
    Name = "terraform-main-public-sn"
  }
}

resource "aws_subnet" "main_app_sn" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.az_a

  tags = {
    Name = "terraform-main-app-sn"
  }
}

resource "aws_subnet" "main_proxy_sn" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.az_a

  tags = {
    Name = "terraform-main-proxy-sn"
  }
}

# ---------------------------
# Internet Gateway
# ---------------------------
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "terraform-main-igw"
  }
}

# ---------------------------
# NAT Gateway
# ---------------------------
# EIPを作成
resource "aws_eip" "nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "main_ngw" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.main_public_sn.id

  tags = {
    Name = "terraform-main-ngw"
  }

  depends_on = [aws_internet_gateway.main_igw]
}

# ---------------------------
# Route table
# ---------------------------
# Route table作成(Public)
resource "aws_route_table" "main_public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }
  tags = {
    Name = "terraform-main-public-rt"
  }
}

# SubnetとRoute tableの関連付け(Public)
resource "aws_route_table_association" "main_public_rt_associate" {
  subnet_id      = aws_subnet.main_public_sn.id
  route_table_id = aws_route_table.main_public_rt.id
}

# Route table作成(App)
resource "aws_route_table" "main_app_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main_ngw.id
  }
  tags = {
    Name = "terraform-main-app-rt"
  }
}

# SubnetとRoute tableの関連付け(App)
resource "aws_route_table_association" "main_app_rt_associate" {
  subnet_id      = aws_subnet.main_app_sn.id
  route_table_id = aws_route_table.main_app_rt.id
}

# Route table作成(Proxy)
resource "aws_route_table" "main_proxy_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main_ngw.id
  }
  tags = {
    Name = "terraform-main-proxy-rt"
  }
}

# SubnetとRoute tableの関連付け(App)
resource "aws_route_table_association" "main_proxy_rt_associate" {
  subnet_id      = aws_subnet.main_proxy_sn.id
  route_table_id = aws_route_table.main_proxy_rt.id
}

# ---------------------------
# Security Group
# ---------------------------
# Security Group作成
resource "aws_security_group" "main_ec2_sg" {
  name        = "terraform-main-ec2-sg"
  description = "For EC2 Linux"
  vpc_id      = aws_vpc.main_vpc.id
  tags = {
    Name = "terraform-main-ec2-sg"
  }

  # インバウンドルール
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.main_eic_sg.id]
  }
  # アウトバウンドルール
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group作成
resource "aws_security_group" "proxy_ec2_sg" {
  name        = "terraform-proxy-ec2-sg"
  description = "For Proxy EC2 Linux"
  vpc_id      = aws_vpc.main_vpc.id
  tags = {
    Name = "terraform-proxy-ec2-sg"
  }

  # インバウンドルール
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.main_eic_sg.id]
  }
  # アウトバウンドルール
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group作成
resource "aws_security_group" "main_eic_sg" {
  name        = "terraform-main-eic-sg"
  description = "For Instance Connect"
  vpc_id      = aws_vpc.main_vpc.id
  tags = {
    Name = "terraform-main-eic-sg"
  }

  # アウトバウンドルール
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}