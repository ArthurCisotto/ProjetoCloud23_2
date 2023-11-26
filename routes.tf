# Tabelas de Rotas
resource "aws_route_table" "arthur_public_rt" {
  vpc_id = aws_vpc.arthur_main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.arthur_igw.id
  }
}

resource "aws_route_table_association" "arthur_rta_public1" {
  subnet_id      = aws_subnet.arthur_public_subnet1.id
  route_table_id = aws_route_table.arthur_public_rt.id
}

resource "aws_route_table_association" "arthur_rta_public2" {
  subnet_id      = aws_subnet.arthur_public_subnet2.id
  route_table_id = aws_route_table.arthur_public_rt.id
}
