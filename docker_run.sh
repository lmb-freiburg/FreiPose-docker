#!/usr/bin/env bash

DOCKER_CMD='docker run --runtime=nvidia';

## Setup X authority such that the container knows how to do graphical stuff
XSOCK="/tmp/.X11-unix";
XAUTH=`tempfile -s .docker.xauth`;
xauth nlist "${DISPLAY}"          \
  | sed -e 's/^..../ffff/'        \
  | xauth -f "${XAUTH}" nmerge -;

${DOCKER_CMD}                     \
  --rm                            \
  --volume "${XSOCK}:${XSOCK}:rw" \
  --volume "${XAUTH}:${XAUTH}:rw" \
  --env "XAUTHORITY=${XAUTH}"     \
  --env DISPLAY                   \
   --volume "${PWD}/data/:/host/:rw"        \
  --hostname "${HOSTNAME}"        \
  --env QT_X11_NO_MITSHM=1 \
-it docker-freipose /bin/bash;


