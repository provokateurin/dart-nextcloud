#!/bin/bash
docker build . -t dart-nextcloud
docker run --rm -p 8080:80 dart-nextcloud
