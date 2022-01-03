variable "name" {
  description = "Logical name of the API."
}

variable "hostname" {
  description = "The hostname of the API endpoint, e.g. api.foo.com."
}

variable "hosted_zone_id" {
  description = "The ID of the hosted zone associated with the domain."
}

variable "certificate_arn" {
  description = "The ARN of the certificate associated with the domain."
}
