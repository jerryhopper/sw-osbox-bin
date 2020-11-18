#!/bin/bash

LATEST=$1
NORELOAD=$2

# helper fuctions
SCRIPT_FILENAME="install-armbian-focal.sh"
telegram()
{
   SCRIPT_FILENAME="install-armbian-focal.sh"
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

# is_command function
is_command() {
    # Checks for existence of string passed in as only function argument.
    # Exit value of 0 when exists, 1 if not exists. Value is the result
    # of the `command` shell built-in call.
    local check_command="$1"
    command -v "${check_command}" >/dev/null 2>&1
}

GetLatestVersion(){
      _ORG_NAME=$1
      _REPO_NAME=$2
      if ! is_command "jq"; then
        LATEST_VERSION=$(curl -s https://api.github.com/repos/${_ORG_NAME}/${_REPO_NAME}/git/refs/heads/master | grep "sha" | cut -d'v' -f2 | cut -d'"' -f4)
      else
        LATEST_VERSION=$(curl -s https://api.github.com/repos/${_ORG_NAME}/${_REPO_NAME}/git/refs/heads/master|jq .object.sha -r )
      fi
      echo $LATEST_VERSION
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


InstallSwoole(){
	# SWOOLE
	log "Cloning and compiling swoole"
	git clone https://github.com/swoole/swoole-src.git && cd swoole-src
	git checkout v4.5.5
	phpize && ./configure --enable-sockets --enable-openssl && ! make && make install
	log "Installing swoole"
	echo "extension=swoole.so" >> $(php -i | grep php.ini|grep Loaded | awk '{print $5}')

	log  "Remove unneccesary files"
	cd .. && rm -rf ./swoole-src
}


## https://github.com/jerryhopper/sw-osbox-bin/archive/b538ec55a7487c6e216a563d38a5e4facf66b6df.tar.gz


# DownloadUnpack "jerryhopper" "sw-osbox" "0.1" "/usr/local/osbox"
DownloadUnpack(){
      ORG_NAME=$1
      REPO_NAME=$2
      LATEST_VERSION=$3
      BIN_DIR=$4

      echo "https://github.com/${ORG_NAME}/${REPO_NAME}/archive/${LATEST_VERSION}.tar.gz"
      # Check the download url, if it responds with 200
      DOWNLOAD_CODE=$(curl -L -s -o /dev/null -I -w "%{http_code}" https://github.com/${ORG_NAME}/${REPO_NAME}/archive/${LATEST_VERSION}.tar.gz)
      if [ "$DOWNLOAD_CODE" != "200" ];then
        echo "Download error! (${DOWNLOAD_CODE}) [https://github.com/${ORG_NAME}/${REPO_NAME}/archive/${LATEST_VERSION}.tar.gz]"
              exit 1
      fi

      # Download the file
      curl -L -o ${REPO_NAME}.tar.gz https://github.com/${ORG_NAME}/${REPO_NAME}/archive/${LATEST_VERSION}.tar.gz
      if [ ! -d ${BIN_DIR} ];then
          mkdir -p ${BIN_DIR}
      fi

      tar -C ${BIN_DIR} -xvf ${REPO_NAME}.tar.gz --strip 1
      rm -rf ${REPO_NAME}.tar.gz

}

function Install (){
  _ORGNAME=$1
  _REPONAME=$2
  _DSTFOLDER=$3
  _INSTALL_MODE=$4

  # check and create /etc/osbox
  if [ ! -d /etc/osbox ]; then
      mkdir -p /etc/osbox
  fi

  # check and create versionfile
  _VERSIONFILE="/etc/osbox/.$_REPONAME.version"
  if [ ! -f "$_VERSIONFILE" ];then
      echo "0">"$_VERSIONFILE"
  fi


  PACKAGE_LOCALVERSION="$(<$_VERSIONFILE)"

  if [ "$_INSTALL_MODE"=="latest" ];then
    echo "Using latest version"
    PACKAGE_REMOTEVERSION="$(GetLatestVersion '$_ORGNAME' '$_REPONAME')"
  else
    echo "Using stable version"
    PACKAGE_REMOTEVERSION="$(GetRemoteVersion '$_ORGNAME' '$_REPONAME')"
  fi

  echo "PACKAGE_REMOTEVERSION='$PACKAGE_REMOTEVERSION'";

  if [ "$PACKAGE_REMOTEVERSION"=="" ];then
    echo "Unexpected version error"
  else
    if [ "$PACKAGE_REMOTEVERSION" != "$PACKAGE_LOCALVERSION" ];then
        echo "Local: $PACKAGE_LOCALVERSION < $PACKAGE_REMOTEVERSION NEEDS UPDATE"
        DownloadUnpack "$_ORGNAME" "$_REPONAME" "$PACKAGE_REMOTEVERSION" "$_DSTFOLDER"
        #/usr/local/osbox/bin/checkpermissions.sh
        echo "$PACKAGE_REMOTEVERSION">$_VERSIONFILE

    else
        echo "$_ORGNAME/$_REPONAME is up to date."
    fi
  fi


}







log "Installation script sw-osbox-bin"

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

log "Adding osbox user"
useradd -m -c "osbox user account" osbox

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
