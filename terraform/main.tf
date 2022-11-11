provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "Low-Main" {
  ami                    = data.aws_ami.ubuntu_latest.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.Low-Main.id]
  root_block_device {
    volume_size = 12
  }
  user_data = file("script.sh")
  key_name  = "flawwwless-frankfurt"
  tags = {
    Name = "Low-Main"
  }
}

resource "aws_eip" "Low-Main" {
  instance = aws_instance.Low-Main.id
}

resource "aws_security_group" "Low-Main" {
  dynamic "ingress" {
    for_each = ["80", "443", "8080", "22"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Low-level-SG"
  }
}

resource "aws_route53_record" "latte_cafe_devdimaops_tech" {
  zone_id = data.aws_route53_zone.standart.zone_id
  name    = "latte-cafe.devdimaops.tech"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.Low-Main.public_ip]
}
