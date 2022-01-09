output "target_group_arn" {
  description = "The ARN of the load balancer's target group."
  value       = aws_lb_target_group.ingress.arn
}
