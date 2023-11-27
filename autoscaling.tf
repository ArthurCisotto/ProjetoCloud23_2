# Auto Scaling Group com Launch Template
resource "aws_launch_template" "arthur_ec2_launch_template" {
  name_prefix   = "arthur-ec2-launch"
  image_id      = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.micro"


    user_data = base64encode(<<-EOF
    #!/bin/bash
    export DEBIAN_FRONTEND=noninteractive
    
    sudo apt-get update
    sudo apt-get install -y python3-pip python3-venv git

    # Criação do ambiente virtual e ativação
    python3 -m venv /home/ubuntu/myappenv
    source /home/ubuntu/myappenv/bin/activate

    # Clonagem do repositório da aplicação
    git clone https://github.com/ArthurCisotto/aplicacao_projeto_cloud.git /home/ubuntu/myapp

    # Instalação das dependências da aplicação
    pip install -r /home/ubuntu/myapp/requirements.txt

    sudo apt-get install -y uvicorn
 
    # Configuração da variável de ambiente para o banco de dados
    export DATABASE_URL="mysql+pymysql://dbadmin:secretpassword@${aws_db_instance.arthur_rds.endpoint}/arthur_db"

    cd /home/ubuntu/myapp
    # Inicialização da aplicação
    uvicorn main:app --host 0.0.0.0 --port 80 
  EOF
  )

  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = aws_subnet.arthur_public_subnet1.id
    security_groups             = [aws_security_group.arthur_sg_for_ec2.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Arthur-instance"
    }
  }
}

resource "aws_autoscaling_group" "arthur_asg" {
  desired_capacity     = 2
  max_size             = 6
  min_size             = 2
  vpc_zone_identifier  = [aws_subnet.arthur_public_subnet1.id, aws_subnet.arthur_public_subnet2.id]
  target_group_arns    = [aws_lb_target_group.arthur_alb_tg.arn]

  launch_template {
    id      = aws_launch_template.arthur_ec2_launch_template.id
    version = "$Latest"
  }

  # Políticas de Escalabilidade
  health_check_type          = "ELB"
  health_check_grace_period  = 300
  force_delete               = true

  tag {
    key                 = "Name"
    value               = "Arthur-ASG-Instance"
    propagate_at_launch = true
  }
}

# CloudWatch Alarm para Escalabilidade
resource "aws_cloudwatch_metric_alarm" "arthur_high_cpu" {
  alarm_name          = "HighCPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This alarm monitors EC2 CPU utilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.arthur_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.arthur_scale_up.arn]
  ok_actions    = [aws_autoscaling_policy.arthur_scale_down.arn]
}

resource "aws_cloudwatch_metric_alarm" "arthur_low_cpu" {
  alarm_name          = "LowCPUUtilization"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"
  alarm_description   = "This alarm monitors EC2 CPU utilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.arthur_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.arthur_scale_down.arn]
  ok_actions    = [aws_autoscaling_policy.arthur_scale_up.arn]
}

# Política de Escalabilidade para Aumentar a Escala
resource "aws_autoscaling_policy" "arthur_scale_up" {
  name                   = "scale_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.arthur_asg.name
}

# Política de Escalabilidade para Reduzir a Escala
resource "aws_autoscaling_policy" "arthur_scale_down" {
  name                   = "scale_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.arthur_asg.name
}
