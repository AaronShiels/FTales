locals {
  name        = "ftales"
  domain_name = "shiels.net.au"
}

module "domain" {
  source = "./modules/domain"
  providers = {
    aws             = aws
    aws.certificate = aws.certificate
  }

  domain_name = local.domain_name
}

module "website" {
  source = "./modules/website"

  domain_name     = local.domain_name
  hosted_zone_id  = module.domain.hosted_zone_id
  certificate_arn = module.domain.certificate_arn
  content_dir     = "${path.module}/dist/client"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available.zone_ids
  private_subnets = [for i in range(1, length(data.aws_availability_zones.available.zone_ids) + 1) : "10.0.${i}.0/24"]
  public_subnets  = [for i in range(1, length(data.aws_availability_zones.available.zone_ids) + 1) : "10.0.10${i}.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

module "api" {
  source = "./modules/api"

  name            = local.name
  hostname        = "api.${local.domain_name}"
  hosted_zone_id  = module.domain.hosted_zone_id
  certificate_arn = module.domain.certificate_arn
}
