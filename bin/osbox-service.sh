#!/bin/bash


#source /usr/local/osbox/lib//is_root
source /usr/local/osbox/bin/fn/log.fn


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
