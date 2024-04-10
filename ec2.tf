# ---------------------------
# Instance Connect
# ---------------------------
resource "aws_ec2_instance_connect_endpoint" "main_eic" {
  subnet_id          = aws_subnet.main_app_sn.id
  security_group_ids = [aws_security_group.main_eic_sg.id]
  preserve_client_ip = true

  tags = {
    Name = "terraform-eic"
  }
}

# ---------------------------
# EC2
# ---------------------------
# EC2作成
resource "aws_instance" "app_ec2" {
  ami                         = "ami-051f8a213df8bc089"
  instance_type               = "t3.micro"
  availability_zone           = var.az_a
  vpc_security_group_ids      = [aws_security_group.main_ec2_sg.id]
  subnet_id                   = aws_subnet.main_app_sn.id
  associate_public_ip_address = "false"

  tags = {
    Name = "terraform-app-ec2"
  }
}

# Proxy EC2作成
resource "aws_instance" "proxy_ec2" {
  ami                         = "ami-051f8a213df8bc089"
  instance_type               = "t3.micro"
  availability_zone           = var.az_a
  vpc_security_group_ids      = [aws_security_group.proxy_ec2_sg.id]
  subnet_id                   = aws_subnet.main_proxy_sn.id
  associate_public_ip_address = "false"
  source_dest_check           = false

  tags = {
    Name = "terraform-proxy-ec2"
  }
}