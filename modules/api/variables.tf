variable "name" {
  description = "Logical name of the API."
}

variable "scale_factor" {
  description = "The number of container instances running for the API."
}

variable "vpc_id" {
  description = "The ID of the VPC for the API resources to be deployed to."
}

variable "private_subnet_ids" {
  description = "The list of internal-facing subnet IDs."
}

variable "public_subnet_ids" {
  description = "The list of internet-facing subnet IDs."
}

variable "hostname" {
  description = "The hostname of the API endpoint, e.g. api.foo.com."
}

variable "origins" {
  description = "The origins that will be communicating with the API, as an array."
}

variable "hosted_zone_id" {
  description = "The ID of the hosted zone associated with the domain."
}

variable "certificate_arn" {
  description = "The ARN of the certificate associated with the domain."
}
