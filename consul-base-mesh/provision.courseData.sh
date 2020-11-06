cat << 'EOFSRSLY' > /tmp/provision.sh
#! /bin/bash

log() {
  echo $(date) - ${@}
}

finish() {
  touch /provision_complete
  log "Complete!  Move on to the next step."
}

finish

EOFSRSLY

while [ ! -f ./config/provision.sh ]; do sleep 1; done; cp ./config/provision.sh /tmp/provision.sh

chmod +rx /tmp/provision.sh
