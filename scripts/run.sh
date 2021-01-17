#!/bin/bash
if [ "$(id -u)" -eq "0" ]; then
  echo "This script mustn't be run with root"
  exit 1
fi

sudo docker build . -t dart-nextcloud
sudo docker run --rm -p 8080:80 dart-nextcloud
