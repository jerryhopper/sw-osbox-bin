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



if [ ! $(id -u osbox) ];then
  log "Adding osbox user"
  useradd -m -c "osbox user account" osbox
fi

INSTALL_MODE="release"
# check if using latest versions
if [ -f /etc/osbox/.dev ];then
   INSTALL_MODE="latest"
fi

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

exit 0








































##############################################################################################
INSTALL_MODE=""
# check if using latest versions
if [ -f /etc/osbox/.dev ];then
   INSTALL_MODE="latest"
fi
















##############################################################################################
## OSBOX BIN
if [ ! -d /etc/osbox ];then
    mkdir -p /etc/osbox
fi
if [ ! -f /etc/osbox/.osbox.bin.version ];then
    echo "0">/etc/osbox/.osbox.bin.version
fi

OSBOX_BIN_LOCALVERSION="$(</etc/osbox/.osbox.bin.version)"
OSBOX_BIN_REMOTEVERSION="$(GetRemoteVersion 'jerryhopper' 'sw-osbox-bin')"

if [ "$INSTALL_MODE" == "latest" ];then
      DownloadLatest "jerryhopper" "sw-osbox-bin" "${OSBOX_BIN_REMOTEVERSION}" "/usr/local/osbox"
      rm -f /sbin/osbox
      ln -s /usr/local/osbox/osbox /sbin/osbox
      chmod +x /usr/local/osbox/osbox
      chmod +x /sbin/osbox
else

  if [ "$OSBOX_BIN_REMOTEVERSION" != "$OSBOX_BIN_LOCALVERSION" ];then
      echo "Remot: $OSBOX_BIN_REMOTEVERSION"
      echo "Local: $OSBOX_BIN_LOCALVERSION"
      echo "NEEDS UPDATE"
      DownloadUnpack "jerryhopper" "sw-osbox-bin" "${OSBOX_BIN_REMOTEVERSION}" "/usr/local/osbox"


      echo "$OSBOX_BIN_REMOTEVERSION">/etc/osbox/.osbox.bin.version
      rm -f /sbin/osbox
      ln -s /usr/local/osbox/osbox /sbin/osbox
      chmod +x /usr/local/osbox/osbox
      chmod +x /sbin/osbox

  else
      echo "osbox-bin is up to date."
  fi
fi



























##############################################################################################
## OSBOX CCORE
if [ ! -f /etc/osbox/.osbox.core.version ];then
    echo "0">/etc/osbox/.osbox.core.version
fi

REPO_ORG="jerryhopper"
REPO_NAME="sw-osbox-core"

OSBOX_CORE_LOCALVERSION="$(</etc/osbox/.osbox.core.version)"
OSBOX_CORE_REMOTEVERSION="$(GetRemoteVersion 'jerryhopper' 'sw-osbox-core')"


if [ "$INSTALL_MODE" == "latest" ];then
  DownloadLatest "jerryhopper" "sw-osbox-core" "${OSBOX_BIN_REMOTEVERSION}" "/usr/local/osbox/project/sw-osbox-core";
else
  if [ "$OSBOX_CORE_REMOTEVERSION" != "$OSBOX_CORE_LOCALVERSION" ];then
      echo "NEEDS UPDATE"

      if [ "$1" == "latest" ];then
        DownloadLatest "jerryhopper" "sw-osbox-core" "${OSBOX_BIN_REMOTEVERSION}" "/usr/local/osbox/project/sw-osbox-core";
      else
        DownloadUnpack "jerryhopper" "sw-osbox-core" "${OSBOX_CORE_REMOTEVERSION}" "/usr/local/osbox/project/sw-osbox-core"
      fi
      echo "$OSBOX_CORE_REMOTEVERSION">/etc/osbox/.osbox.core.version
  else
      echo "osbox-core is up to date."
  fi
fi



























##############################################################################################
## Enable the service
if [ ! -f /etc/systemd/system/osbox.service ];then
  ln -s /usr/local/osbox/lib/systemd/osbox.service /etc/systemd/system/osbox.service
fi
## Flag service active
if [ ! -f /etc/systemd/system/multi-user.target.wants/osbox.service ];then
  ln -s /usr/local/osbox/lib/systemd/osbox.service /etc/systemd/system/multi-user.target.wants/osbox.service
fi


bash /usr/local/osbox/bin/checkpermissions.sh







##  systemctl daemon-reload is needed to activate the above.
exit 0




