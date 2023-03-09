locals {
  service_names    = ["api", "ui"]
  ecs_cluster_name = "my-ecs-cluster"
}

module "this" {
  for_each = toset(local.service_names)

  source = "../"

  service_name     = each.key
  ecs_cluster_name = local.ecs_cluster_name
}
