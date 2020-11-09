#!/bin/bash

# cat /etc/os-release

# is_command function
is_command() {
    # Checks for existence of string passed in as only function argument.
    # Exit value of 0 when exists, 1 if not exists. Value is the result
    # of the `command` shell built-in call.
    local check_command="$1"
    command -v "${check_command}" >/dev/null 2>&1
}


DownloadLatest(){
      _ORG_NAME=$1
      _REPO_NAME=$2
      _LATEST_VERSION=$3
      _BIN_DIR=$4

      echo "Downloading ${_ORG_NAME}/${_REPO_NAME} latest"
      #https://github.com/jerryhopper/sw-osbox-bin/archive/master.zip

      # Check the download url, if it responds with 200
      DOWNLOAD_CODE=$(curl -L -s -o /dev/null -I -w "%{http_code}" --silent --output /dev/null  https://github.com/${_ORG_NAME}/${_REPO_NAME}/archive/master.tar.gz)
      if [ "$DOWNLOAD_CODE" != "200" ];then
        log "Download error! ( ${DOWNLOAD_CODE} ) https://github.com/${_ORG_NAME}/${_REPO_NAME}/archive/master.tar.gz"
              exit 1
      fi

      # Download the file
      curl -L -o master.tar.gz https://github.com/${_ORG_NAME}/${_REPO_NAME}/archive/master.tar.gz &> /dev/null
      mkdir -p ${_BIN_DIR}
      tar -C ${_BIN_DIR} -xf master.tar.gz --strip 1 > /dev/null
      rm -rf master.tar.gz
      echo "ok"
}


GetRemoteVersion(){
      _ORG_NAME=$1
      _REPO_NAME=$2
      if ! is_command "jq"; then
        LATEST_VERSION=$(curl -s https://api.github.com/repos/${_ORG_NAME}/${_REPO_NAME}/releases/latest | grep "tag_name" | cut -d'v' -f2 | cut -d'"' -f4)
      else
        LATEST_VERSION=$(curl -s https://api.github.com/repos/${_ORG_NAME}/${_REPO_NAME}/releases/latest|jq .tag_name -r )
      fi
      echo $LATEST_VERSION
}

DownloadUnpack(){
      _ORG_NAME=$1
      _REPO_NAME=$2
      _LATEST_VERSION=$3
      _BIN_DIR=$4

      echo "https://github.com/${_ORG_NAME}/${_REPO_NAME}/archive/${_LATEST_VERSION}.tar.gz"
      # Check the download url, if it responds with 200
      DOWNLOAD_CODE=$(curl -L -s -o /dev/null -I -w "%{http_code}" https://github.com/${_ORG_NAME}/${_REPO_NAME}/archive/${_LATEST_VERSION}.tar.gz)
      if [ "$DOWNLOAD_CODE" != "200" ];then
        log "Download error! ( ${DOWNLOAD_CODE} ) "https://github.com/${_ORG_NAME}/${_REPO_NAME}/archive/${_LATEST_VERSION}.tar.gz""
              exit 1
      fi

      # Download the file
      curl -s -L -o ${_REPO_NAME}.tar.gz https://github.com/${_ORG_NAME}/${_REPO_NAME}/archive/${_LATEST_VERSION}.tar.gz &> /dev/null
      mkdir -p ${_BIN_DIR}
      tar -C ${_BIN_DIR} -xf ${_REPO_NAME}.tar.gz --strip 1 > /dev/null
      rm -rf ${_REPO_NAME}.tar.gz
      echo "ok"
}


telegram()
{
   SCRIPT_FILENAME="install.sh"
   local VARIABLE=${1}
   curl -s -X POST https://api.surfwijzer.nl/blackbox/api/telegram \
        -H "User-Agent: surfwijzerblackbox" \
        -H "Cache-Control: private, max-age=0, no-cache" \
        -H "X-Script: $SCRIPT_FILENAME" \
        -e "$SCRIPT_FILENAME" \
        -d text="$SCRIPT_FILENAME : $VARIABLE" >/dev/null
}


# installation log
log(){
    echo "$(date) : $1">>/var/osbox-install.log
    echo "$(date) : $1"
    if [ -f /etc/osbox/osbox.db ];then
      sqlite3 -batch /etc/osbox/osbox.db "insert INTO installog ( f ) VALUES( '$1' );"
    fi
    telegram "$1"
}



log "update.sh"

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

INSTALL_MODE=""
# check if using latest versions
if [ -f /etc/osbox/.dev ];then
   INSTALL_MODE="latest"
else










## OSBOX BIN
if [ ! -f /etc/osbox ];then
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

chmod +x /usr/local/osbox/osbox
chmod +x /sbin/osbox
chmod +x /usr/sbin/osbox




if [ ! -f /etc/systemd/system/osbox.service ];then
  ln -s /usr/local/osbox/lib/systemd/osbox.service /etc/systemd/system/osbox.service
fi
if [ ! -f /etc/systemd/system/multi-user.target.wants/osbox.service ];then
  ln -s /usr/local/osbox/lib/systemd/osbox.service /etc/systemd/system/multi-user.target.wants/osbox.service
fi



exit 0
