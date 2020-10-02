#!/bin/bash
if [ ! -d /var/osbox/response ]; then
  mkdir -p /var/osbox/response
fi
# make the pipe
rm -rf /var/osbox/mypipe
if [ ! -f /var/osbox/mypipe ]; then
  mkfifo /var/osbox/mypipe
fi
while true; do
  IFS=
  COMMAND="$(cat /var/osbox/mypipe)"
  echo "$COMMAND" > /var/osbox/response/pipe;
  eval $COMMAND &>> /var/osbox/response/pipe;
  done
