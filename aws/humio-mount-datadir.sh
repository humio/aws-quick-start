#!/bin/bash
set -e
set -x

FSREADY="false"

### Is there a data volume attached to sdh?
DISK=`file -s /dev/xvdh | grep "No such file or dir" | wc -l`
if [ "$DISK" == "1" ]; then
    echo "ERROR: /dev/xvdh (sdh) does not exist! Attach a data volume to the EC2 instance."
    exit 1
fi

### Does the data device contain a filesystem?
DISK=`file -s /dev/xvdh | grep "ext4 filesystem" | wc -l`
if [ "$DISK" == "1" ] ; then
    echo "File system exist"
    FSREADY="true"
fi

### Does the data device cantain no filesystem?
DISK=`file -s /dev/xvdh | grep "/dev/xvdh: data" | wc -l`
if [ "$DISK" == "1" ] ; then
    echo "No filesystem, formatting disk"
    mkfs -t ext4 /dev/xvdh
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
mount /dev/xvdh /data/ || true

