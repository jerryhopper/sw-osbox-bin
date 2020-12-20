#!/bin/bash


#source /usr/local/osbox/lib//is_root
source /usr/local/osbox/bin/fn/log.fn
source /usr/local/osbox/bin/fn/IsOnline.fn


systemctl stop serial-getty@ttyS0.service

if [ -f /etc/cron.d/osbox-daily ];then
  osbox cron create
fi




if [ ! -f /etc/osbox/.deviceID ];then
    echo -n "$(cat /proc/sys/kernel/random/uuid)">/etc/osbox/.deviceID
fi


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

if [ "${IsOnline}"=="YES" ]; then

   /usr/local/osbox/osbox update
   # Apply code updates
   #bash /usr/local/osbox/bin/update.sh
   # Run database updgrades
   #bash /usr/local/osbox/project/sw-osbox-core/src/sh/database/update.sh

fi


if [ ! -f /etc/osbox/.authorization ];then
   /usr/local/osbox/osbox unregistered
fi


##################################################################################################
# start the service.
log "osbox-service.sh started"
#/usr/bin/php /usr/local/osbox/project/sw-osbox-core/src/www/server.php

/usr/bin/php /usr/local/osbox/project/sw-osbox-core/src/WebSocketServer/server.php

exit
