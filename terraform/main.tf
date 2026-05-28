module "vpc" {
  source      = "./modules/vpc"
  app_name    = var.app_name
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
}

module "ecr" {
  source   = "./modules/ecr"
  app_name = var.app_name
}

module "alb" {
  source            = "./modules/alb"
  app_name          = var.app_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.vpc.alb_sg_id
}

module "ecs" {
  source             = "./modules/ecs"
  app_name           = var.app_name
  environment        = var.environment
  aws_region         = var.aws_region
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  app_sg_id          = module.vpc.app_sg_id
  ecr_image_url      = module.ecr.repository_url
  alb_target_group   = module.alb.target_group_arn
  desired_count      = var.desired_count
  container_port     = var.container_port
}

module "asg" {
  source        = "./modules/asg"
  app_name      = var.app_name
  ecs_cluster   = module.ecs.cluster_name
  ecs_service   = module.ecs.service_name
  min_count     = var.min_count
  max_count     = var.max_count
  alb_arn_suffix = module.alb.alb_arn_suffix
  tg_arn_suffix  = module.alb.tg_arn_suffix
}

module "monitoring" {
  source       = "./modules/monitoring"
  app_name     = var.app_name
  ecs_cluster  = module.ecs.cluster_name
  alb_arn      = module.alb.alb_arn
  alert_email  = var.alert_email
}
