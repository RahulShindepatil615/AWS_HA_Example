data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical

}

data "aws_vpc" "vpcDetails" {
  default = true
}

data "aws_subnets" "subnetDetails" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpcDetails.id]
  }

}

locals {
  subnetIds = slice(data.aws_subnets.subnetDetails.ids, 0, 2)
}

resource "aws_instance" "web" {
  count = 2
  #ami
  ami = data.aws_ami.ubuntu.id
  #subnets
  subnet_id = local.subnetIds[count.index]
  #security group
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  instance_type          = "t3.micro"
  user_data              = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Web Instance ${count.index + 1}</h1>" > /var/www/html/index.html
              EOF
  tags = {
    Name = "web-${count.index + 1}"
  }

}