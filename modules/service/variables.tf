variable "name" {
  description = "Logical name of the API."
}

variable "image" {
  description = "The full image tag to be pulled and run, e.g. \"registry/repo:latest\"."
}

variable "scale_factor" {
  description = "The number of container instances running for the API."
}

variable "port_mapping" {
  description = "Mapping of ports from host to container, e.g. \"80\": \"5000\"."
  type        = map(string)
}

variable "environment" {
  description = "The environment variables for the container."
  type        = map(string)
}

variable "health_check_url" {
  description = "The URL associated with the service's HTTP health check, e.g. http://localhost:80/health."
}

variable "vpc_id" {
  description = "The ID of the VPC for the API resources to be deployed to."
}

variable "cluster_id" {
  description = "The ID of the ECS Cluster for the service to run within."
}

variable "subnet_ids" {
  description = "The list of subnet IDs for the service to be associated with."
}
