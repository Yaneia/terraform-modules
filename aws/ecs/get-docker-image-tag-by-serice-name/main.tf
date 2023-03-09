data "external" "this" {
  program = ["/bin/bash", "${path.module}/bin/this.sh"]
  query = {
    ecs_cluster_name = var.ecs_cluster_name,
    service_name     = var.ecs_service_name,
  }
}
