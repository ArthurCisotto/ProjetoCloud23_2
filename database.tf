resource "aws_db_subnet_group" "arthur_db_subnet_group" {
  name       = "arthur-db-subnet-group"
  subnet_ids = [aws_subnet.arthur_private_subnet1.id, aws_subnet.arthur_private_subnet2.id]
  tags = {
    Name = "Arthur DB Subnet Group"
  }
}

# Exemplo de configuração de um banco de dados RDS MySQL
resource "aws_db_instance" "arthur_rds" {
  db_name             = "arthur_db"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  username             = "dbadmin"
  password             = "secretpassword"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.arthur_db_sg.id]
  db_subnet_group_name = aws_db_subnet_group.arthur_db_subnet_group.name

  # Habilitar backups automáticos e definir janela de manutenção
  backup_retention_period = 7 # dias
  backup_window = "03:00-04:00"
  maintenance_window = "Sun:04:30-Sun:05:30"


  # Habilitar Multi-AZ
  multi_az = true
}
