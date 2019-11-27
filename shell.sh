#!/bin/bash

source CONFIG

docker exec \
  --interactive --tty \
  --env TERM=${TERM} \
  --env COLUMNS=${COLUMNS} \
  ${container_name} \
  bash
