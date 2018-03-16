#!/bin/bash
set -e
set -x

DIR=`dirname $0`

apt-get update
apt-get -y install curl

cat << EOF | tee humio-limits.conf
# Added by humio provisioning script: Raise limits for files.
* soft nofile 250000
* hard nofile 250000
EOF
cp humio-limits.conf /etc/security/limits.d/humio-limits.conf

cat << EOF | tee 99-humio.conf
# Allow larger backlog of incoming TCP connections:
net.core.somaxconn=4096
net.ipv4.tcp_max_syn_backlog=4096
# Allow larger buffer of incoming data in particular needed for UDP:
net.core.rmem_max=16777216
EOF
cp 99-humio.conf /etc/sysctl.d/99-humio.conf

# install docker
if [ ! -f "/usr/bin/docker" ]; then
    curl -fsSL https://get.docker.com/ | sh
fi

# Ensure that a Humio configuration file exists
if [ ! -e /etc/humio.conf ]; then
    echo "" > /etc/humio.conf
fi

service docker restart
docker pull humio/humio
docker run --name=humio -d --restart=always -v /data:/data --net=host --env-file /etc/humio.conf humio/humio
