provider "aws" {
  region = "ap-south-1"
}

resource "random_id" "rand" {
  byte_length = 4
}

resource "aws_s3_bucket" "arpit_bucket" {
  bucket = "arpit0234-${random_id.rand.hex}"
  tags = {
    Name        = "ArpitBucket"
    Environment = "Dev"
  }
}

resource "aws_vpc" "arpit_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "ArpitVPC"
  }
}

resource "aws_subnet" "arpit_subnet" {
  vpc_id                  = aws_vpc.arpit_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "ArpitSubnet"
  }
}

resource "aws_internet_gateway" "arpit_igw" {
  vpc_id = aws_vpc.arpit_vpc.id
  tags = {
    Name = "ArpitIGW"
  }
}

resource "aws_route_table" "arpit_rt" {
  vpc_id = aws_vpc.arpit_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.arpit_igw.id
  }
  tags = {
    Name = "ArpitRouteTable"
  }
}

resource "aws_route_table_association" "arpit_rta" {
  subnet_id      = aws_subnet.arpit_subnet.id
  route_table_id = aws_route_table.arpit_rt.id
}

resource "aws_security_group" "arpit_sg" {
  name        = "arpit-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.arpit_vpc.id

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

  tags = {
    Name = "ArpitSecurityGroup"
  }
}

resource "aws_instance" "arpit_ec2" {
  ami                         = "ami-02d26659fd82cf299"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.arpit_subnet.id
  vpc_security_group_ids      = [aws_security_group.arpit_sg.id]
  associate_public_ip_address = true
  key_name                    = "terra-key"

  tags = {
    Name = "ArpitEC2"
  }
}

output "ec2_public_ip" {
  value = aws_instance.arpit_ec2.public_ip
}

output "s3_bucket_name" {
  value = aws_s3_bucket.arpit_bucket.bucket
}