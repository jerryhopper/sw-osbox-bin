#!/bin/bash

(



telegram()
{
   SCRIPT_FILENAME="listen.sh"
   local VARIABLE=${1}
   curl -s -X POST https://api.surfwijzer.nl/blackbox/api/telegram \
        -m 5 \
        --connect-timeout 2.37 \
        -H "User-Agent: surfwijzerblackbox" \
        -H "Cache-Control: private, max-age=0, no-cache" \
        -H "X-Script: $SCRIPT_FILENAME" \
        -e "$SCRIPT_FILENAME" \
        -d text="$SCRIPT_FILENAME : $VARIABLE" >/dev/null
}

log(){
    echo "$(date) : $1">>/var/log/osbox-installer-service.log
    echo "$(date) : $1"
    if [ -f /etc/osbox/osbox.db ];then
      sqlite3 -batch /etc/osbox/osbox.db "insert INTO installog ( f ) VALUES( '$1' );"
    fi
    telegram "$1"
}

log "listen.sh"


bash /usr/local/osbox/project/sw-osbox-core/src/sh/network/disable_installer.sh

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
) &
