#!/bin/bash
set -ea


#PATH=/home/coder/bin:/sbin:/usr/sbin:$PATH dockerd-rootless.sh
#[INFO] Make sure the following environment variables are set (or add them to ~/.bashrc):
# WARNING: systemd not found. You have to remove XDG_RUNTIME_DIR manually on every logout.
export XDG_RUNTIME_DIR=/home/coder/.docker/run
export PATH=/home/coder/bin:$PATH
export DOCKER_HOST=unix:///home/coder/.docker/run/docker.sock


#PATH=/home/coder/bin:/sbin:/usr/sbin:$PATH 

dumb-init /home/coder/bin/dockerd-rootless.sh

dumb-init /home/coder/code-server-3.9.0 "$@"


#dumb-init /home/coder/.local/bin/code-server
