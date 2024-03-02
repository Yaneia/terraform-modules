locals {
  service_names    = ["api", "ui"]
  ecs_cluster_name = "dev"
}

module "get_docker_image_tag_by_task_id" {
  for_each = toset(local.service_names)

  source = "../"

  service_name     = each.key
  ecs_cluster_name = local.ecs_cluster_name
}
