provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "lab" {
  cidr_block           = "10.30.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name    = "tf-vpc"
    Project = "hybrid-lab"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.30.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "tf-public-a"
    Project = "hybrid-lab"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.30.2.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
tags = {
    Name    = "tf-public-b"
    Project = "hybrid-lab"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.30.3.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = false
tags = {
    Name    = "tf-private-a"
    Project = "hybrid-lab"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.30.4.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = false
tags = {
    Name    = "tf-private-b"
    Project = "hybrid-lab"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id                  = aws_vpc.lab.id


tags = {
   Name     =  "tf-igw"
   Project  =  "hybrid-lab"
  }
}
      

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "tf-public-rt"
    Project = "hybrid-lab"
  }
}





resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.lab.id


  tags = {
    Name    = "tf-private-rt"
    Project = "hybrid-lab"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt.id
}

variable "my_ip" {
  type        = string
  description = "My public IP with /32"
}

resource "aws_security_group" "bastion_sg" {
  name        = "tf-bastion-sg"
  description = "SSH from my IP to the bastion"
  vpc_id      = aws_vpc.lab.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "tf-bastion-sg"
    Project = "hybrid-lab"
  }
}


resource "aws_security_group" "web_sg" {
  name        = "tf-web-sg"
  description = "HTTP and HTTPS from internet, SSH from bastion"
  vpc_id      = aws_vpc.lab.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "tf-web-sg"
    Project = "hybrid-lab"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "tf-app-sg"
  description = "bastion and web allow to app-server"
  vpc_id      = aws_vpc.lab.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "tf-app-sg"
    Project = "hybrid-lab"
  }
}



































