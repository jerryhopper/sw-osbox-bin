#!/bin/bash
if [ ! -d /var/osbox/response ]; then
  mkdir -p /var/osbox/response
fi
while true; do
  IFS=
  COMMAND="$(cat /var/osbox/mypipe)"
  echo "$COMMAND" > /var/osbox/response/pipe;
  eval $COMMAND &>> /var/osbox/response/pipe;
  done
