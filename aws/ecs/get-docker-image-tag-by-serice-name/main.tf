data "external" "service" {
  program = ["/bin/sh", "${path.module}/bin/this.sh"]
  query = {
    ecs_cluster_name = var.ecs_cluster_name,
    service_name     = var.service_name,
  }
}
