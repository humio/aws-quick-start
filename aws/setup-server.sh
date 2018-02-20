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

cp $DIR/humio-mount-datadir.service /etc/systemd/system/
systemctl enable humio-mount-datadir.service
systemctl daemon-reload
systemctl start humio-mount-datadir

#install docker
if [ ! -f "/usr/bin/docker" ]; then
    curl -fsSL https://get.docker.com/ | sh
fi

service docker restart

### If we haven't got a humio configuration file we should create a default one matching the about of memory availabe on the instance
if [ ! -e /etc/humio.conf ]; then
    MEM=`cat /proc/meminfo | grep MemTotal | sed -r 's/MemTotal: +(.*) kB/\1/'`
    if   (( MEM  > 16000000 )) ; then   echo "HUMIO_JVM_ARGS=-Xmx8G -Xss2M -XX:MaxDirectMemorySize=32G"   > /etc/humio.conf
    elif (( MEM  >  8000000 )) ; then   echo "HUMIO_JVM_ARGS=-Xmx4G -Xss2M -XX:MaxDirectMemorySize=32G"   > /etc/humio.conf
    elif (( MEM  >  4000000 )) ; then   echo "HUMIO_JVM_ARGS=-Xmx2G -Xss2M -XX:MaxDirectMemorySize=32G"   > /etc/humio.conf
    elif (( MEM  >  2000000 )) ; then   echo "HUMIO_JVM_ARGS=-Xmx1G -Xss2M -XX:MaxDirectMemorySize=32G"   > /etc/humio.conf
    else
        echo "ERROR: Not enough memory"
        exit 3
    fi
fi

docker login $1
docker pull humio/humio
docker run --name=humio -d --restart=always -v /data:/data --net=host --env-file /etc/humio.conf humio/humio
