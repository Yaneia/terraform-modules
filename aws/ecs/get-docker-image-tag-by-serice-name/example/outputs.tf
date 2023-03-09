output "service_name_to_image_version_map" {
  value = {
    for service_name in local.service_names :
    service_name => module.this[service_name].service_docker_image_tag
  }
  description = "Map of service names to docker image tags"
}
