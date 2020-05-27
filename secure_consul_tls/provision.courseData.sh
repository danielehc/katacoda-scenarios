cat << 'EOFSRSLY' > /tmp/provision.sh
#! /bin/bash

log() {
  echo $(date) - ${1}
}

finish() {
  touch /provision_complete
  log "Complete!  Move on to the next step."
}

log Install Consul locally



finish

EOFSRSLY

chmod +x /tmp/provision.sh
