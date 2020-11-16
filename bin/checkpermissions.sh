#!/bin/bash

if [ -f "/usr/local/osbox/osbox" ];then
  if [ ! -x "/usr/local/osbox/osbox" ];then
    chmod +x /usr/local/osbox/osbox
  fi
fi

if [ -f "/sbin/osbox" ];then
  if [ ! -x "/sbin/osbox" ];then
    chmod +x /sbin/osbox
  fi
fi

if [ -f "/usr/sbin/osbox" ];then
  if [ ! -x "/usr/sbin/osbox" ];then
    chmod +x /usr/sbin/osbox
  fi
fi

if [ -f "/usr/local/osbox/bin/update.sh" ];then
  if [ ! -x "/usr/local/osbox/bin/update.sh" ];then
    chmod +x /usr/local/osbox/bin/update.sh
  fi
fi

if [ -f "/usr/local/osbox/bin/osbox-service.sh" ];then
  if [ ! -x "/usr/local/osbox/bin/osbox-service.sh" ];then
    chmod +x /usr/local/osbox/bin/osbox-service.sh
  fi
fi
