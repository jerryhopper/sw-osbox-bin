#!/bin/bash

telegram()
{
   SCRIPT_FILENAME="osbox-service.sh"
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

#source /usr/local/osbox/lib//is_root
#source /usr/local/osbox/lib/bashfunc/is_command


##################################################################################################
## Kill the swoole process if it hasnt ended yet.
if [ -f /run/swoole.pid ];then
  kill -USR1 $(cat /run/swoole.pid)
  sleep 1
fi

# Checks
# database update check
#sqlite3 -batch /etc/osbox/osbox.db "create table if not exists version (id INTEGER PRIMARY KEY,Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,f TEXT);"
#echo $?




##################################################################################################
## Connectivity and update check.
ONLINE="NO"
if : >/dev/tcp/8.8.8.8/53; then
  ONLINE="YES"
fi
if : >/dev/tcp/1.1.1.1/53; then
  ONLINE="YES"
fi
if [ "$ONLINE"=="YES" ]; then
   bash /usr/local/osbox/bin/update.sh
fi







##################################################################################################
# start the service.
log "osbox-service.sh started"
/usr/bin/php /usr/local/osbox/project/sw-osbox-core/src/www/server.php

exit
