# VPC
resource "aws_vpc" "arthur_main_vpc" {
  cidr_block = "10.0.0.0/23"
  tags = {
    Name = "arthur-vpc"
  }
}

# Subnets Públicas
resource "aws_subnet" "arthur_public_subnet1" {
  vpc_id                  = aws_vpc.arthur_main_vpc.id
  cidr_block              = "10.0.0.0/27"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
}

resource "aws_subnet" "arthur_public_subnet2" {
  vpc_id                  = aws_vpc.arthur_main_vpc.id
  cidr_block              = "10.0.0.32/27"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
}

# Subnet Privada
resource "aws_subnet" "arthur_private_subnet1" {
  vpc_id                  = aws_vpc.arthur_main_vpc.id
  cidr_block              = "10.0.1.0/27"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1b"
}

resource "aws_subnet" "arthur_private_subnet2" {
  vpc_id                  = aws_vpc.arthur_main_vpc.id
  cidr_block              = "10.0.1.32/27"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1a"
}

# Internet Gateway
resource "aws_internet_gateway" "arthur_igw" {
  vpc_id = aws_vpc.arthur_main_vpc.id
}
