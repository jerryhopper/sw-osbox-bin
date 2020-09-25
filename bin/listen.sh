#!/bin/bash
if [ ! -d /var/osbox/response ]; then
  mkdir -p /var/osbox/response
fi
while true; do eval "$(cat /var/osbox/mypipe)" &>/var/osbox/reponse/pipe; done
