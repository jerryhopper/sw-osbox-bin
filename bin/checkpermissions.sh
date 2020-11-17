#!/bin/bash


# Permission for binaries
if [ -f "/usr/local/osbox/osbox" ];then
  if [ ! -x "/usr/local/osbox/osbox" ];then
    echo "Fixing permissions for /usr/local/osbox/osbox"
    chmod +x /usr/local/osbox/osbox
  fi
fi


if [ -f "/usr/local/osbox/bin/update.sh" ];then
  if [ ! -x "/usr/local/osbox/bin/update.sh" ];then
    echo "Fixing permissions for /usr/local/osbox/bin/update.sh"
    chmod +x /usr/local/osbox/bin/update.sh
  fi
fi

if [ -f "/usr/local/osbox/bin/osbox-service.sh" ];then
  if [ ! -x "/usr/local/osbox/bin/osbox-service.sh" ];then
    echo "Fixing permissions for /usr/local/osbox/bin/osbox-service.sh"
    chmod +x /usr/local/osbox/bin/osbox-service.sh
  fi
fi


# Symlink checks


# test if symlink is broken (by seeing if it links to an existing file)
#if [ ! -e "/sbin/osbox" ] ; then
#    # code if the symlink is broken
#    echo "!"
#fi

if [ -f "/sbin/osbox" ];then
  if [ ! -x "/sbin/osbox" ];then
    echo "Fixing permissions for /sbin/osbox"
    chmod +x /sbin/osbox
  fi
fi

if [ -f "/usr/sbin/osbox" ];then
  if [ ! -x "/usr/sbin/osbox" ];then
    echo "Fixing permissions for /usr/sbin/osbox"
    chmod +x /usr/sbin/osbox
  fi
fi
