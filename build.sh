#!/bin/bash

source CONFIG

sed -e "s/@@HOSTNAME@@/${hostname}/g" \
    -e "s/@@SMTP_SERVER@@/${smtp_server}/g" \
    -e "s/@@VMWARE_PERL_SDK@@/${vmware_perl_sdk}/g" \
    buildenv/Dockerfile.in > buildenv/Dockerfile

docker build $@ -t ${container_name} -f buildenv/Dockerfile buildenv/
