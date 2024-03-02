#!/bin/bash
# example usage:
#   echo '{"ecs_cluster_name":"ecs-cluster", "service_name":"ecs-service"}' | ./this.sh

# parse arguments with jq and assign to variables
eval "$(jq -r '@sh "ecs_cluster_name=\(.ecs_cluster_name) service_name=\(.service_name)"')"

# get task definition from the service and cluster names
TASK_DEFINITION=$(aws ecs describe-services \
  --cluster $ecs_cluster_name \
  --services $service_name \
  --query 'services[0].deployments[0].taskDefinition' \
  --output json | jq -r '. | split("/") | .[-1]')

# get image version from the task definition
IMAGE_VERSION=$(aws ecs describe-task-definition \
  --task-definition $TASK_DEFINITION \
  --query 'taskDefinition.containerDefinitions[0].image' \
  --output json | jq -r '. | split(":") | .[-1]')

# return $IMAGE_VERSION in json format
jq -n --arg image_version "$IMAGE_VERSION" '{"image_version":$image_version}'