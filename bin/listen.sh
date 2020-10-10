#!/bin/bash
if [ ! -d /var/osbox ]; then
  mkdir -p /var/osbox
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
