#!/bin/bash
if [ "$(id -u)" -eq "0" ]; then
  echo "This script mustn't be run with root"
  exit 1
fi

function cleanup() {
  echo "Stopping container"
  sudo docker stop "$CONTAINER_ID"
}
trap cleanup EXIT

sudo docker build . -t dart-nextcloud

echo "Starting container"
# shellcheck disable=SC2155
export CONTAINER_ID=$(sudo docker run -d --rm -p 8080:80 dart-nextcloud)

dart --no-sound-null-safety test "$@"
