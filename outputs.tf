output "link_to_docs" {
  value = "http://${aws_lb.arthur_alb.dns_name}/docs"
}