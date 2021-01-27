#!/bin/bash

source CONFIG

docker run -d \
 --restart=always \
 -p ${host_port}:80 \
 -p 6557:6557 \
 -v "${host_volumes_path}/volumes/etc/centreon:/etc/centreon" \
 -v "${host_volumes_path}/volumes/etc/centreon-engine:/etc/centreon-engine" \
 -v "${host_volumes_path}/volumes/etc/centreon-broker:/etc/centreon-broker" \
 -v "${host_volumes_path}/volumes/var/lib/centreon-broker:/var/lib/centreon-broker" \
 -v "${host_volumes_path}/volumes/var/log/centreon-broker:/var/log/centreon-broker" \
 -v "${host_volumes_path}/volumes/var/lib/centreon-engine:/var/lib/centreon-engine" \
 -v "${host_volumes_path}/volumes/var/log/centreon-engine:/var/log/centreon-engine" \
 -v "${host_volumes_path}/volumes/var/lib/centreon:/var/lib/centreon" \
 --cap-add=SYS_PTRACE \
 --hostname "${hostname}" \
 --name "${container_name}" \
 --restart always \
 "${container_name}" ${@}
