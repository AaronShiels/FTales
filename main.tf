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

resource "aws_ecs_cluster" "services" {
  name = local.name
}

resource "aws_ecr_repository" "api" {
  name = "${local.name}-api"
}

module "api" {
  source = "./modules/service"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  cluster_id = aws_ecs_cluster.services.id

  name             = "api"
  image            = "${aws_ecr_repository.api.repository_url}:latest"
  scale_factor     = 1
  port_mapping     = { "80" : "80" }
  health_check_url = "http://localhost:80/health"
  environment = {
    "ORIGINS" : join(",", [for hostname in module.website.hostnames : "https://${hostname}"])
  }
}
