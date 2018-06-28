#!/bin/bash
set -e
set -x

DIR=`dirname $0`

### Install service for formatting the data volume if necessary and mount to /data
cp $DIR/humio-mount-datadir.service /etc/systemd/system/
systemctl enable humio-mount-datadir.service
systemctl daemon-reload
systemctl start humio-mount-datadir

### If we haven't got a humio configuration file we should create a default one
### matching the about of memory availabe on the instance
if [ ! -e /etc/humio.conf ]; then
    MEM=`cat /proc/meminfo | grep MemTotal | sed -r 's/MemTotal: +(.*) kB/\1/'`
    if   (( MEM  > 16000000 )) ; then
        echo "HUMIO_JVM_ARGS=-Xmx8G -Xss2M -XX:MaxDirectMemorySize=32G" > /etc/humio.conf
    elif (( MEM  >  8000000 )) ; then
        echo "HUMIO_JVM_ARGS=-Xmx4G -Xss2M -XX:MaxDirectMemorySize=32G" > /etc/humio.conf
    elif (( MEM  >  4000000 )) ; then
        echo "HUMIO_JVM_ARGS=-Xmx2G -Xss2M -XX:MaxDirectMemorySize=32G" > /etc/humio.conf
    elif (( MEM  >  2000000 )) ; then
        echo "HUMIO_JVM_ARGS=-Xmx1G -Xss2M -XX:MaxDirectMemorySize=32G" > /etc/humio.conf
    else
        echo "ERROR: Not enough memory"
        exit 3
    fi
    INSTANCEID=`curl http://169.254.169.254/latest/meta-data/instance-id`
    echo "AUTHENTICATION_METHOD=single-user" >> /etc/humio.conf
    echo "SINGLE_USER_PASSWORD=${INSTANCEID}" >> /etc/humio.conf
fi
