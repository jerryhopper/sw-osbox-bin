#!/bin/bash
if [ ! -d /var/osbox/response ]; then
  mkdir -p /var/osbox/response
fi
# make the pipe
rm -rf /var/osbox/pipe
if [ ! -f /var/osbox/pipe ]; then
  mkfifo /var/osbox/pipe
fi
while true; do
  IFS=
  COMMAND="$(cat /var/osbox/pipe)"
  echo "$COMMAND" > /var/osbox/response;
  eval $COMMAND &>> /var/osbox/response;
  done
