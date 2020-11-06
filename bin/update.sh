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
      curl -L -o ${REPO_NAME}.tar.gz https://github.com/${ORG_NAME}/${REPO_NAME}/archive/${LATEST_VERSION}.tar.gz
      mkdir -p ${BIN_DIR}
      tar -C ${BIN_DIR} -xvf ${REPO_NAME}.tar.gz --strip 1
      rm -rf ${REPO_NAME}.tar.gz
}

## OSBOX BIN
if [ ! -f /etc/osbox/.osbox.bin.version ];then
    echo "0">/etc/osbox/.osbox.bin.version
fi

OSBOX_BIN_LOCALVERSION="$(</etc/osbox/.osbox.bin.version)"
OSBOX_BIN_REMOTEVERSION="$(GetRemoteVersion 'jerryhopper' 'sw-osbox-bin')"

if [ "$OSBOX_BIN_REMOTEVERSION" != "$OSBOX_BIN_LOCALVERSION" ];then
    echo "Remot: $OSBOX_BIN_REMOTEVERSION"
    echo "Local: $OSBOX_BIN_LOCALVERSION"
    echo "NEEDS UPDATE"
    DownloadUnpack "jerryhopper" "sw-osbox-bin" "${OSBOX_BIN_REMOTEVERSION}" "/usr/local/osbox"
    echo "$OSBOX_BIN_REMOTEVERSION">/etc/osbox/.osbox.bin.version
fi


## OSBOX CCORE
if [ ! -f /etc/osbox/.osbox.core.version ];then
    echo "0">/etc/osbox/.osbox.core.version
fi

OSBOX_CORE_LOCALVERSION="$(</etc/osbox/.osbox.core.version)"
OSBOX_CORE_REMOTEVERSION="$(GetRemoteVersion 'jerryhopper' 'sw-osbox-core')"

if [ "$OSBOX_CORE_REMOTEVERSION" != "$OSBOX_CORE_LOCALVERSION" ];then
    echo "NEEDS UPDATE"
    DownloadUnpack "jerryhopper" "sw-osbox-core" "${OSBOX_CORE_REMOTEVERSION}" "/usr/local/osbox/projects/sw-osbox-core"
    echo "$OSBOX_CORE_REMOTEVERSION">/etc/osbox/.osbox.core.version
fi











#DownloadUnpack "jerryhopper" "sw-osbox-bin" "/root/projects"


#LATEST_VERSION=$(curl -s https://api.github.com/repos/jerryhopper/sw-osbox-bin/releases/latest | grep "tag_name" | cut -d'v' -f2 | cut -d'"' -f4)

#echo $LATEST_VERSION




#DownloadUnpack "jerryhopper" "sw-osbox-bin" "/usr/local/osbox/projects"


# LATEST_VERSION=$(curl -s https://api.github.com/repos/jerryhopper/sw-osbox-image/releases/latest | grep "tag_name" | cut -d'v' -f2 | cut -d'"' -f1)



























