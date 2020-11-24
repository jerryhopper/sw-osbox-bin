#!/bin/bash


setExecutable(){
  _file=$1
  # Permission for binaries
  if [ -f "$_file" ];then
    if [ ! -x "$_file" ];then
      echo "Fixing permissions for $_file"
      chmod +x $_file
    fi
  fi
}
checkSymlink (){
  _SYMINK=$1
  _EXE=$2
  if [ ! -f "$_SYMINK" ];then
    echo "Symlink doesnt exist $_SYMLINK"
    ln -s $_EXE $_SYMINK
  fi
  if [ -e "$_SYMINK" ] ; then
      # code if the symlink is broken
      echo "Dangling symlink found! $_SYMLINK"
      rm -f $_SYMINK
      ln -s $_EXE $_SYMINK
  fi
  setExecutable "$_SYMINK"
}


if [ -f /etc/osbox/osbox.db ];then
    chmod 0777 /etc/osbox/osbox.db
fi

# Permission for binaries
setExecutable "/usr/local/osbox/osbox"
setExecutable "/usr/local/osbox/bin/update.sh"
setExecutable "/usr/local/osbox/bin/osbox-service.sh"


# Symlink checks
checkSymlink "/sbin/osbox" "/usr/local/osbox/osbox"

