#!/bin/bash

source /usr/local/osbox/bin/fn/GetLatestVersion.fn
source /usr/local/osbox/bin/fn/GetRemoteVersion.fn
source /usr/local/osbox/bin/fn/InstallSwoole.fn
source /usr/local/osbox/bin/fn/DownloadUnpack.fn
source /usr/local/osbox/bin/fn/Install.fn
source /usr/local/osbox/bin/fn/log.fn
source /usr/local/osbox/bin/fn/is_command.fn


# cat /etc/os-release


log "update.sh"
##############################################################################################
# Root check
if [[ ! $EUID -eq 0 ]];then
  if [[ -x "$(command -v sudo)" ]]; then
    exec sudo bash "$0" "$@"
    exit $?
  else
    log "   sudo is needed to run the installer.  Please run this script as root or install sudo."
    exit 1
  fi
fi


# Check and install requirements.
bash /usr/local/osbox/bin/checkrequirements.sh



#if [ ! $(id -u osbox) ];then
#  log "Adding osbox user"
  useradd -m -c "osbox user account" osbox
#fi

INSTALL_MODE="release"
# check if using latest versions
if [ -f /etc/osbox/.dev ];then
   INSTALL_MODE="latest"
fi
echo "Mode: $INSTALL_MODE"
# Install the applications
Install "jerryhopper" "sw-osbox-bin" "/usr/local/osbox" "$INSTALL_MODE"

Install "jerryhopper" "sw-osbox-core" "/usr/local/osbox/project/sw-osbox-core" "$INSTALL_MODE"

# Check and set permissions
bash /usr/local/osbox/bin/checkpermissions.sh

## Enable the service
if [ ! -f /etc/systemd/system/osbox.service ];then
  ln -s /usr/local/osbox/lib/systemd/osbox.service /etc/systemd/system/osbox.service
fi

# Flag service active
if [ ! -f /etc/systemd/system/multi-user.target.wants/osbox.service ];then
  ln -s /usr/local/osbox/lib/systemd/osbox.service /etc/systemd/system/multi-user.target.wants/osbox.service
fi



#You can also trigger the hot code reloading with Linux signals:
# kill -USR1 MASTER_PID
#Only restart the task processes by signal
# kill -USR2 MASTER_PID

if [ -f /run/swoole.pid ];then
  echo "Reloading swoole"
  kill -USR1 $(cat /run/swoole.pid)
  sleep 1
fi


exit 0





