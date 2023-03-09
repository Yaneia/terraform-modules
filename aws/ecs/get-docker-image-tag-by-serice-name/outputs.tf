output "service_docker_image_tag" {
  value       = data.external.this.result["image_version"]
  description = "Running docker image tag for the service."
}
