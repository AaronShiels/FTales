variable "name" {
  description = "Logical name of the resource set the ingress is for."
}

variable "vpc_id" {
  description = "The ID of the VPC for the API resources to be deployed to."
}

variable "subnet_ids" {
  description = "The list of subnet IDs for the service to be associated with."
}

variable "target_port" {
  description = "The target port to forward traffic to."
  type        = number
}

variable "target_health_check_path" {
  description = "The path of the target's HTTP health check, e.g. /health."
}

variable "hostname" {
  description = "The full hostname for the ingress path, e.g. api.foo.com."
}

variable "hosted_zone_id" {
  description = "The ID of the hosted zone associated with the ingress path."
}
