# Elastic IP para NAT Gateway
resource "aws_eip" "arthur_eip" {
  depends_on = [aws_internet_gateway.arthur_igw]
  domain    = "vpc"
  tags = {
    Name = "arthur_EIP_for_NAT"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "arthur_nat_gateway" {
  allocation_id = aws_eip.arthur_eip.id
  subnet_id     = aws_subnet.arthur_public_subnet1.id
  tags = {
    Name = "Arthur NAT Gateway"
  }
  depends_on = [aws_internet_gateway.arthur_igw]
}

# Tabela de Rotas para Subnet Privada
resource "aws_route_table" "arthur_private_rt" {
  vpc_id = aws_vpc.arthur_main_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.arthur_nat_gateway.id
  }
}

resource "aws_route_table_association" "arthur_rta_private" {
  subnet_id      = aws_subnet.arthur_private_subnet.id
  route_table_id = aws_route_table.arthur_private_rt.id
}
