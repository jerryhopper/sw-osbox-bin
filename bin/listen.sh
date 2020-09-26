#!/bin/bash
if [ ! -d /var/osbox/response ]; then
  mkdir -p /var/osbox/response
fi
while true; do
  #myData="$(cat /var/osbox/mypipe)"
  #echo "$myData"&>/var/osbox/response/pipe;
  eval "$(cat /var/osbox/mypipe)"&>/var/osbox/response/pipe;
  echo "******">>/var/osbox/response/pipe;
  echo "$(cat /var/osbox/mypipe)">>/var/osbox/response/pipe;
  done
