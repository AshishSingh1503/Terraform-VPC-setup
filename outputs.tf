output "vpc_id" {
  value = aws_vpc.main.id
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "alb_dns" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.web_alb.dns_name
}
