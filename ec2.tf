# ------------------------------
# IAM Role
# ------------------------------
# IAM Policy Document
data "aws_iam_policy_document" "assumerole_ec2" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ssm" {
  name               = "ec2-ssm-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assumerole_ec2.json

  tags = {
    Roles = "ssm"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ------------------------------
# Instance Profile
# ------------------------------
resource "aws_iam_instance_profile" "ssm" {
  name = "ec2-ssm-role"
  role = aws_iam_role.ssm.name

  tags = {
    Roles = "ssm"
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

  iam_instance_profile = aws_iam_instance_profile.ssm.name

  tags = {
    Name = "terraform-app-ec2"
  }
}

# # Proxy EC2作成
# resource "aws_instance" "proxy_ec2" {
#   ami                         = "ami-051f8a213df8bc089"
#   instance_type               = "t3.micro"
#   availability_zone           = var.az_a
#   vpc_security_group_ids      = [aws_security_group.proxy_ec2_sg.id]
#   subnet_id                   = aws_subnet.main_proxy_sn.id
#   associate_public_ip_address = "false"
#   source_dest_check           = false

#   iam_instance_profile = aws_iam_instance_profile.ssm.name

#   tags = {
#     Name = "terraform-proxy-ec2"
#   }
# }