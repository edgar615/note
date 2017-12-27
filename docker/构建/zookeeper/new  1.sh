ZK_HOST_INTERFACE=
ZK_HOST_ADDRESS=
if [ -z "$ZK_HOST_INTERFACE" ]
then
	ZK_HOST_INTERFACE=eth0
fi

if [ -n "$ZK_HOST_INTERFACE" ]; then
  ZK_HOST_ADDRESS=$(ip -o -4 addr list $ZK_HOST_INTERFACE | head -n1 | awk '{print $4}' | cut -d/ -f1)
fi

if [ -z "$ZK_HOST_ADDRESS" ]; then
	echo "Could not find IP for interface '$ZK_HOST_INTERFACE', exiting"
	exit 1
fi

echo "==> Found address '$ZK_HOST_ADDRESS' for interface '$ZK_HOST_INTERFACE', setting bind option..."

ZK_DATA_DIR=/zookeeper/data