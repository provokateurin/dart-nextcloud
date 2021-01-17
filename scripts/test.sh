#!/bin/bash
function cleanup() {
  echo "Stopping container"
  docker stop "$CONTAINER_ID"
}
trap cleanup EXIT

docker build . -t dart-nextcloud

echo "Starting container"
# shellcheck disable=SC2155
export CONTAINER_ID=$(docker run -d --rm -p 8080:80 dart-nextcloud)

dart --no-sound-null-safety test "$@"
