#!/bin/bash
set -e
#set -x

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


if [ `mount | grep '/humiocache' | wc -l` == "1" ] ; then
    echo "Cache drive already mounted. Fine."
else
    echo "If we find emphemeral disk(s) for cache, mount them now..."
    if [ "$EBSDEV" == "/dev/nvme1n1" ]; then
	CACHE_PATTERN="/dev/nvme[23456789]n1"
    else
	CACHE_PATTERN="/dev/nvme[0123456789]n1"
    fi

    CACHE_DRIVES=`ls $CACHE_PATTERN | xargs`
    if [ "x$CACHE_DRIVES" == "x" ]; then
	echo "No cache drives detected."
    else
	echo "Cache drives detected: $CACHE_DRIVES"
	sudo apt-get -qy install parted
	mkdir -p /humiocache || umount /humiocache || true
	COUNT=`echo $CACHE_DRIVES | wc -w`
	if [ "$count" == "1" ] ; then
	    blkdiscard -v $CACHE_DRIVES
	    mkfs.ext4 -T huge $CACHE_DRIVES
	    mount $CACHE_DRIVES /humiocache
	else
	    for drv in $CACHE_DRIVES; do
		blkdiscard -v $drv
		sudo parted -s ${drv} mklabel gpt
	    done
	    mdadm --misc --force -S /dev/md7 || true
	    mdadm --create --metadata=default --run --force --chunk=512 /dev/md7 --level=0 --raid-devices=$COUNT $CACHE_DRIVES
	    mkfs.ext4 -T huge -E nodiscard /dev/md7
	    mount /dev/md7 /humiocache
	    mkdir /humiocache/cache
	fi
    fi
fi
