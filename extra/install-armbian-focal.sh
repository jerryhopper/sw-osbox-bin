#!/bin/bash



# helper fuctions
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
    #telegram "$1"
}

# is_command function
is_command() {
    # Checks for existence of string passed in as only function argument.
    # Exit value of 0 when exists, 1 if not exists. Value is the result
    # of the `command` shell built-in call.
    local check_command="$1"
    command -v "${check_command}" >/dev/null 2>&1
}



# GetLatestVersion.fn
GetLatestVersion(){
      _ORG_NAME=$1
      _REPO_NAME=$2
      if ! is_command "jq"; then
        echo "$(curl -s "https://api.github.com/repos/$_ORG_NAME/$_REPO_NAME/git/refs/heads/master" | grep "sha" | cut -d'v' -f2 | cut -d'"' -f4)"
      else
        echo "$(curl -s "https://api.github.com/repos/$_ORG_NAME/$_REPO_NAME/git/refs/heads/master"|jq .object.sha -r )"
      fi
}

# GetRemoteVersion.fn
GetRemoteVersion(){
      _ORG_NAME=$1
      _REPO_NAME=$2
      if ! is_command "jq"; then
        echo "$(curl -s "https://api.github.com/repos/$_ORG_NAME/$_REPO_NAME/releases/latest" | grep "tag_name" | cut -d'v' -f2 | cut -d'"' -f4)"
      else
        echo "$(curl -s "https://api.github.com/repos/$_ORG_NAME/$_REPO_NAME/releases/latest"|jq .tag_name -r )"
      fi
}

# InstallSwoole.fn
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

# DownloadUnpack.fn
DownloadUnpack(){
      ORG_NAME=$1
      REPO_NAME=$2
      LATEST_VERSION=$3
      BIN_DIR=$4


      # Check the download url, if it responds with 200
      DOWNLOAD_CODE=$(curl -L -s -o /dev/null -I -w "%{http_code}" https://github.com/${ORG_NAME}/${REPO_NAME}/archive/${LATEST_VERSION}.tar.gz)
      if [ "$DOWNLOAD_CODE" != "200" ];then
        log "Download error! (${DOWNLOAD_CODE}) [https://github.com/${ORG_NAME}/${REPO_NAME}/archive/${LATEST_VERSION}.tar.gz]"
        exit 1
      fi

      # Download the file
      #log "Downloading https://github.com/${ORG_NAME}/${REPO_NAME}/archive/${LATEST_VERSION}.tar.gz"
      curl -s -L -o ${REPO_NAME}.tar.gz https://github.com/${ORG_NAME}/${REPO_NAME}/archive/${LATEST_VERSION}.tar.gz >/dev/null
      if [ $? != 0 ]; then
        log "Error during download"
        exit 1
      fi

      if [ ! -d ${BIN_DIR} ];then
          mkdir -p ${BIN_DIR}
      fi

      log "Extracting ${LATEST_VERSION}.tar.gz"
      tar -C ${BIN_DIR} -xvf ${REPO_NAME}.tar.gz --strip 1 >/dev/null

      if [ $? != 0 ]; then
        log "Error during extraction"
        exit 1
      fi


      rm -rf ${REPO_NAME}.tar.gz
      if [ $? != 0 ]; then
        log "Error removing tar archive"
        exit 1
      fi

}

# Install.fn
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
      echo "0">$_VERSIONFILE
  fi
  PACKAGE_LOCALVERSION="$(<$_VERSIONFILE)"

  #echo "PACKAGE_LOCALVERSION='$PACKAGE_LOCALVERSION'";

  if [ "$_INSTALL_MODE" == "latest" ];then
    log "Using latest (unstable) commit"
    PACKAGE_REMOTEVERSION=$(GetLatestVersion "$_ORGNAME" "$_REPONAME")
  else
    log "Using latest stable release"
    PACKAGE_REMOTEVERSION=$(GetRemoteVersion "$_ORGNAME" "$_REPONAME")
  fi

  #echo "PACKAGE_REMOTEVERSION='$PACKAGE_REMOTEVERSION'";

  if [ "$PACKAGE_REMOTEVERSION" == "" ];then
    log "Unexpected version error"
  else
    if [ "$PACKAGE_REMOTEVERSION" != "$PACKAGE_LOCALVERSION" ];then
        log "Local: $PACKAGE_LOCALVERSION < $PACKAGE_REMOTEVERSION NEEDS UPDATE"
        DownloadUnpack "$_ORGNAME" "$_REPONAME" "$PACKAGE_REMOTEVERSION" "$_DSTFOLDER"
        #/usr/local/osbox/bin/checkpermissions.sh
        echo "$PACKAGE_REMOTEVERSION">$_VERSIONFILE

    else
        log "$_ORGNAME/$_REPONAME is up to date."
    fi
  fi


}







log "install-armbian-focal.sh"





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


## Enable the systemd-service
if [ ! -f /etc/systemd/system/osbox.service ];then
  ln -s /usr/local/osbox/lib/systemd/osbox.service /etc/systemd/system/osbox.service
fi

# Flag service systemd-active
if [ ! -f /etc/systemd/system/multi-user.target.wants/osbox.service ];then
  ln -s /usr/local/osbox/lib/systemd/osbox.service /etc/systemd/system/multi-user.target.wants/osbox.service
fi

# Copy the avahi service def
if [ ! -f /etc/avahi/services/osbox.service ];then
  cp /usr/local/osbox/lib/avahi/osbox.service /etc/avahi/services/osbox.service
fi

#copy the resolv.conf
#if [ ! -f /etc/systemd/resolv.conf ];then
cp -f /usr/local/osbox/lib/systemd/resolved.conf /etc/systemd/resolved.conf
#fi

# FusionAuth Idpserver specific information.
echo "idp.surfwijzer.nl">/etc/osbox/.idp_server
echo "89d998a5-aaef-45d0-9765-adf1f3e00c65">/etc/osbox/.client_id

echo "https://setup.surfwijzer.nl">/etc/osbox/.backendhost

exit 0








