#!/bin/bash

source CONFIG

sed -e "s/@@HOSTNAME@@/${hostname}/g" \
    -e "s/@@SMTP_SERVER@@/${smtp_server}/g" \
    buildenv/Dockerfile.in > buildenv/Dockerfile

docker build $@ -t ${container_name} -f buildenv/Dockerfile buildenv/
