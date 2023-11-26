
# Security Groups para as instâncias EC2 (regras de entrada e saída)
resource "aws_security_group" "arthur_sg_for_ec2" {
  name        = "arthur-sg-for-ec2"
  description = "Security Group for EC2 Instances"
  vpc_id      = aws_vpc.arthur_main_vpc.id

  # Regras de entrada (permitir tráfego HTTP)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regras de saída (liberar todo o tráfego)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group para o Load Balancer (regras de entrada e saída)
resource "aws_security_group" "arthur_sg_for_alb" {
  name        = "arthur-sg-for-alb"
  description = "Security Group for Application Load Balancer"
  vpc_id      = aws_vpc.arthur_main_vpc.id

  # Regras de entrada (permitir tráfego HTTP e HTTPS)
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

  # Regras de saída (liberar todo o tráfego)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group para o RDS (regras de entrada e saída)
resource "aws_security_group" "arthur_db_sg" {
  name        = "arthur-db-sg"
  description = "Security Group for RDS"
  depends_on = [aws_vpc.arthur_main_vpc]
  vpc_id      = aws_vpc.arthur_main_vpc.id

  # Regras de entrada (permitir tráfego MySQL)
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.arthur_sg_for_ec2.id] # Permitir que as instâncias EC2 se conectem ao RDS
  }

  # Regras de saída (liberar todo o tráfego)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
