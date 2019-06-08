#!/bin/bash
set -e
set -x

# If we haven't got a humio configuration file we should create a default one
# matching the amout of memory availabe on the instance

if [ ! -e /etc/humio.conf ]; then
    MEM=`cat /proc/meminfo | grep MemTotal | sed -r 's/MemTotal: +(.*) kB/\1/'`
    if   (( MEM  > 64000000 )) ; then
        echo "HUMIO_JVM_ARGS=-Xmx32G -Xss2M -XX:MaxDirectMemorySize=64G" > /etc/humio.conf
    elif   (( MEM  > 32000000 )) ; then
        echo "HUMIO_JVM_ARGS=-Xmx16G -Xss2M -XX:MaxDirectMemorySize=32G" > /etc/humio.conf
    elif   (( MEM  > 16000000 )) ; then
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
    if [ -d "/humiocache" ]; then
	echo "CACHE_STORAGE_DIRECTORY=/humiocache" >> /etc/humio.conf
	echo "CACHE_STORAGE_PERCENTAGE=90" >> /etc/humio.conf
    fi
fi


FSREADY="false"

### Is there a data volume attached to sdh?
EBSDEV=/dev/xvdh
DISK=`file -s $EBSDEV | grep "No such file or dir" | wc -l`
if [ "$DISK" == "1" ]; then
    # Try the layout used on m5d:
    EBSDEV=/dev/nvme1n1
    DISK=`file -s $EBSDEV | grep "No such file or dir" | wc -l`
fi
if [ "$DISK" == "1" ]; then
    echo "ERROR: /dev/xvdh (sdh) and /dev/nvme1n1 does not exist! Attach a data volume to the EC2 instance."
    exit 1
fi

### Does the data device contain a filesystem?
DISK=`file -s $EBSDEV | grep "ext4 filesystem" | wc -l`
if [ "$DISK" == "1" ] ; then
    echo "File system exist"
    FSREADY="true"
fi

### Does the data device cantain no filesystem?
DISK=`file -s $EBSDEV | grep "$EBSDEV: data" | wc -l`
if [ "$DISK" == "1" ] ; then
    echo "No filesystem, formatting disk"
    mkfs -t ext4 $EBSDEV
    FSREADY="true"
fi

### If we are not ready by now we should abort.
if [ "$FSREADY" == "false" ] ; then
    echo "ERROR: Something unexpected happned. Contact support@humio.com"
    exit 2
fi

### Mounting the data volume
echo "Mounting disk at /data"
mkdir -p /data
mount $EBSDEV /data/ || true

docker run --name=humio -d --restart=always -v /data:/data --net=host --env-file /etc/humio.conf humio/humio
