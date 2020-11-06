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

GetRemoteVersion(){
      ORG_NAME=$1
      REPO_NAME=$2
      if ! is_command "jq"; then
        LATEST_VERSION=$(curl -s https://api.github.com/repos/${ORG_NAME}/${REPO_NAME}/releases/latest | grep "tag_name" | cut -d'v' -f2 | cut -d'"' -f4)
      else
        LATEST_VERSION=$(curl -s https://api.github.com/repos/${ORG_NAME}/${REPO_NAME}/releases/latest|jq .tag_name -r )
      fi
      echo $LATEST_VERSION
}


DownloadLatest(){
      ORG_NAME=$1
      REPO_NAME=$2
      LATEST_VERSION=$3
      BIN_DIR=$4

      echo "Downloading ${ORG_NAME}/${REPO_NAME} latest"
      #https://github.com/jerryhopper/sw-osbox-bin/archive/master.zip

      # Check the download url, if it responds with 200
      DOWNLOAD_CODE=$(curl -L -s -o /dev/null -I -w "%{http_code}" --silent --output /dev/null  https://github.com/${ORG_NAME}/${REPO_NAME}/archive/master.tar.gz)
      if [ "$DOWNLOAD_CODE" != "200" ];then
        echo "Download error! ( ${DOWNLOAD_CODE} )"
              exit 1
      fi

      # Download the file
      curl -s -L -o master.tar.gz https://github.com/${ORG_NAME}/${REPO_NAME}/archive/master.tar.gz &> /dev/null
      mkdir -p ${BIN_DIR}
      tar -C ${BIN_DIR} -xf master.tar.gz --strip 1 > /dev/null
      rm -rf master.tar.gz
}


DownloadUnpack(){
      ORG_NAME=$1
      REPO_NAME=$2
      LATEST_VERSION=$3
      BIN_DIR=$4

      echo "https://github.com/${ORG_NAME}/${REPO_NAME}/archive/${LATEST_VERSION}.tar.gz"
      # Check the download url, if it responds with 200
      DOWNLOAD_CODE=$(curl -L -s -o /dev/null -I -w "%{http_code}" https://github.com/${ORG_NAME}/${REPO_NAME}/archive/${LATEST_VERSION}.tar.gz)
      if [ "$DOWNLOAD_CODE" != "200" ];then
        echo "Download error! ( ${DOWNLOAD_CODE} )"
              exit 1
      fi

      # Download the file
      curl -s -L -o ${REPO_NAME}.tar.gz https://github.com/${ORG_NAME}/${REPO_NAME}/archive/${LATEST_VERSION}.tar.gz &> /dev/null
      mkdir -p ${BIN_DIR}
      tar -C ${BIN_DIR} -xf ${REPO_NAME}.tar.gz --strip 1 > /dev/null
      rm -rf ${REPO_NAME}.tar.gz
}

## OSBOX BIN
if [ ! -f /etc/osbox/.osbox.bin.version ];then
    echo "0">/etc/osbox/.osbox.bin.version
fi

OSBOX_BIN_LOCALVERSION="$(</etc/osbox/.osbox.bin.version)"
OSBOX_BIN_REMOTEVERSION="$(GetRemoteVersion 'jerryhopper' 'sw-osbox-bin')"

if [ "$1" == "latest" ];then
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


if [ "$1" == "latest" ];then
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

echo "Checking service"
if [ ! -f /etc/systemd/system/osbox.service ];then
  ln -s /usr/local/osbox/lib/systemd/osbox.service /etc/systemd/system/osbox.service
fi

systemctl enable osbox.service

if [ "$2" == "noreload" ];then
  echo "no systemctl daemon-reload"
else
  systemctl daemon-reload
fi










#DownloadUnpack "jerryhopper" "sw-osbox-bin" "/root/projects"


#LATEST_VERSION=$(curl -s https://api.github.com/repos/jerryhopper/sw-osbox-bin/releases/latest | grep "tag_name" | cut -d'v' -f2 | cut -d'"' -f4)

#echo $LATEST_VERSION




#DownloadUnpack "jerryhopper" "sw-osbox-bin" "/usr/local/osbox/projects"


# LATEST_VERSION=$(curl -s https://api.github.com/repos/jerryhopper/sw-osbox-image/releases/latest | grep "tag_name" | cut -d'v' -f2 | cut -d'"' -f1)



























