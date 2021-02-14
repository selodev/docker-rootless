#!/bin/bash

# https://docs.docker.com/engine/security/rootless/
# https://stackoverflow.com/questions/63482865/how-to-set-modprobe-overlay-permit-mounts-in-userns-1

# Paquetería previa (Ubuntu + Debian)
sudo apt update
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    uidmap \
    iptables \
    wget

#echo "net.ipv4.ip_unprivileged_port_start=0" | tee -a /etc/sysctl.d/50-rootless.conf
#sysctl --system

# Particularidades Debian
modificacionKernelparaDebian(){
    # Set kernel.unprivileged_userns_clone
    echo "kernel.unprivileged_userns_clone = 1" | sudo tee -a /etc/sysctl.d/50-rootless.conf
    sudo sysctl --system

    #echo "options overlay permit_mounts_in_userns=1" | sudo tee -a /etc/modprobe.d/rootless.conf
    #sudo modprobe overlay permit_mounts_in_userns=1
    # Load ip_tables module
    sudo modprobe ip_tables
}

# TODO: support printing non-essential but recommended instructions:
# - sysctl: "net.ipv4.ping_group_range"
# - sysctl: "net.ipv4.ip_unprivileged_port_start"

# Instalación de Docker
distro=$(awk '{ print $1 }' /etc/issue)

if [ "$distro" = "Debian" ]
        modificacionKernelparaDebian
fi

curl -fsSL https://get.docker.com/rootless | sh
