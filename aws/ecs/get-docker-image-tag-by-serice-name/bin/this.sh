#!/bin/bash

# function to generate AWS v4 signature
aws_sign_v4_curl() {
  access_key="$AWS_ACCESS_KEY_ID"
  secret_key="$AWS_SECRET_ACCESS_KEY"
  region="$2"
  service="$1"
  http_method="POST"
  endpoint="$3"
  content_type="application/json"
  body="$4"

  # calculate date values
  amz_date="$(date -u "+%Y%m%dT%H%M%SZ")"
  datestamp="$(date -u "+%Y%m%d")"
  credential_scope="${datestamp}/${region}/${service}/aws4_request"

  # generate canonical request
  canonical_uri="/"
  canonical_query=""
  canonical_headers="content-type:${content_type}\nhost:${endpoint}\nx-amz-date:${amz_date}\n"
  signed_headers="content-type;host;x-amz-date"
  payload_hash="$(echo -n "${body}" | openssl dgst -sha256 -hex | sed 's/^.* //')"
  canonical_request="${http_method}\n${canonical_uri}\n${canonical_query}\n${canonical_headers}\n${signed_headers}\n${payload_hash}"

  # generate string to sign
  algorithm="AWS4-HMAC-SHA256"
  credential="${access_key}/${credential_scope}"
  string_to_sign="${algorithm}\n${amz_date}\n${credential_scope}\n$(echo -n "${canonical_request}" | openssl dgst -sha256 -hex | sed 's/^.* //')"

  # generate signing key
  kdate="$(echo -n "${datestamp}" | openssl dgst -sha256 -hex -mac HMAC -macopt "key:${algorithm}${secret_key}" | sed 's/^.* //')"
  kregion="$(echo -n "${region}" | openssl dgst -sha256 -hex -mac HMAC -macopt "key:${kdate}" | sed 's/^.* //')"
  kservice="$(echo -n "${service}" | openssl dgst -sha256 -hex -mac HMAC -macopt "key:${kregion}" | sed 's/^.* //')"
  ksigning="$(echo -n "aws4_request" | openssl dgst -sha256 -hex -mac HMAC -macopt "key:${kservice}" | sed 's/^.* //')"

  # generate signature
  signature="$(echo -n "${string_to_sign}" | openssl dgst -sha256 -hex -mac HMAC -macopt "key:${ksigning}" | sed 's/^.* //')"

  # output signed request headers
  printf "X-Amz-Date: ${amz_date}\n"
  printf "Authorization: ${algorithm} Credential=${credential}, SignedHeaders=${signed_headers}, Signature=${signature}\n"
}

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