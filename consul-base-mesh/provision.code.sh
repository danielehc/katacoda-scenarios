ls -l /tmp

while [ ! -f /tmp/provision.sh ]; do sleep 1; done; /tmp/provision.sh