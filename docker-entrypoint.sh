#!/bin/bash
set -ea


#PATH=/home/coder/bin:/sbin:/usr/sbin:$PATH dockerd-rootless.sh
#[INFO] Make sure the following environment variables are set (or add them to ~/.bashrc):
# WARNING: systemd not found. You have to remove XDG_RUNTIME_DIR manually on every logout.

#PATH=/home/coder/bin:/sbin:/usr/sbin:$PATH
export XDG_RUNTIME_DIR=/home/coder/.docker/run
export PATH=/home/coder/bin:$PATH
export DOCKER_HOST=unix:///home/coder/.docker/run/docker.sock


export PATH=/home/coder/bin:/sbin:/usr/sbin:$PATH 


#PATH=/home/coder/bin:/sbin:/usr/sbin:$PATH 


dumb-init dockerd-rootless.sh


export PATH=/home/coder/.local/bin:$PATH
#unshare -m -U /bin/bash
#nsenter -U --preserve-credentials -n -m -t $(cat $XDG_RUNTIME_DIR/docker.pid)

dumb-init code-server "$@"


#dumb-init /home/coder/.local/bin/code-server
