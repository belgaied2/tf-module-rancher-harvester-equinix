#!/bin/bash
while true; do
  if curl -sk --max-time 5 https://$IP/version|grep gitVersion; then
    echo "completed"
    rsync -e 'ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i '$SSH_PRIVATE_KEY_FILE --rsync-path="sudo rsync" rancher@$IP:/etc/rancher/rke2/rke2.yaml ../$NAME-rke2.yaml
    if [[ `uname` == "Darwin" ]]; then
      sed -i '' 's/127.0.0.1/'$IP'/g' ../$NAME-rke2.yaml
    else
      sed -i 's/127.0.0.1/'$IP'/g' ../$NAME-rke2.yaml
    fi
    exit 0
  fi
  sleep 5
done
