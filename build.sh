#!/bin/bash

source CONFIG

sed -e "s/@@HOSTNAME@@/${hostname}/g" \
    -e "s/@@SMTP_SERVER@@/${smtp_server}/g" \
    -e "s/@@VMWARE_PERL_SDK@@/${vmware_perl_sdk}/g" \
    buildenv/Dockerfile.in > buildenv/Dockerfile

if [ -f "buildenv/Dockerfile.local" ]; then
  sed -i -e '/^@@DOCKERFILELOCAL@@$/{r buildenv/Dockerfile.local' -e 'd}' buildenv/Dockerfile
else
  sed -i 's/^@@DOCKERFILELOCAL@@$//' buildenv/Dockerfile
fi

docker build $@ -t ${container_name} -f buildenv/Dockerfile buildenv/
