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
        echo "Download error! (${DOWNLOAD_CODE}) [https://github.com/${ORG_NAME}/${REPO_NAME}/archive/${LATEST_VERSION}.tar.gz]"
              exit 1
      fi

      # Download the file
      curl -L -o ${REPO_NAME}.tar.gz https://github.com/${ORG_NAME}/${REPO_NAME}/archive/${LATEST_VERSION}.tar.gz
      mkdir -p ${BIN_DIR}
      tar -C ${BIN_DIR} -xvf ${REPO_NAME}.tar.gz --strip 1
      rm -rf ${REPO_NAME}.tar.gz
}


InstallSwoole(){
	# SWOOLE
	log "Cloning and compiling swoole"
	git clone https://github.com/swoole/swoole-src.git && cd swoole-src
	git checkout v4.5.5
	phpize && ./configure --enable-sockets --enable-openssl && make && make install
	log "Installing swoole"
	echo "extension=swoole.so" >> $(php -i | grep php.ini|grep Loaded | awk '{print $5}')

	log  "Remove unneccesary files"
	cd .. && rm -rf ./swoole-src
}

InstallPreRequisites(){
	#
	export LANG=C LC_ALL="en_US.UTF-8"
	export DEBIAN_FRONTEND=noninteractive
	export APT_LISTCHANGES_FRONTEND=none
	sudo apt-get update
	sudo apt-get install -y jq git unzip
	#apt-get install -y docker docker.io avahi-daemon avahi-utils libsodium23 build-essential libzip5 libedit2 libxslt1.1 nmap curl jq wget git unzip sqlite3 php-dev


	# remove new user prompt
	rm /root/.not_logged_in_yet
	# change to weak password
	# echo "root:password" | chpasswd

	#/usr/lib/armbian/armbian-firstrun



	# SWOOLE
	InstallSwoole


	sudo apt-get -y remove build-essential
	sudo apt -y autoremove && apt clean


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


exitcode="0"
if ! is_command "docker" ;then
   echo "Docker not available"
   exitcode="1"
fi
if ! is_command "avahi-daemon" ;then
   echo "Avahi-daemon not available"
   exitcode="1"
fi
if ! is_command "sqlite3" ;then
   echo "Sqlite not available"
   exitcode="1"
fi

if ! is_command "unzip" ;then
   echo "unzip not available"
   exitcode="1"
fi

if ! is_command "php" ;then
   echo "php not available"
   exitcode="1"
fi

if [ "$(php -m|grep swoole)" != "swoole" ];then
  echo "no swoole available"
  exitcode="1"
fi

log "-----------"
exitcode="1"
if [ $exitcode == "1" ] ;then
   log "requirements not met, aborting"
   #InstallPreRequisites
   #exit 1
fi


log "Adding osbox user"
useradd -m -c "osbox user account" osbox



if [ ! -f /usr/local/osbox/bin/update.sh ]; then
  # osbox not installed.
  ## OSBOX BIN
  if [ ! -d /etc/osbox ]; then
      mkdir -p /etc/osbox
  fi
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
      rm -f /sbin/osbox
      ln -s /usr/local/osbox/osbox /sbin/osbox
      chmod +x /usr/local/osbox/osbox
      chmod +x /sbin/osbox
      chmod +x /usr/sbin/osbox
  else
      echo "osbox-bin is up to date."
  fi
else
  echo "osbox executable is available"

fi

#/usr/local/osbox/project/sw-osbox-core/osbox-service.sh

#if [ "$LATEST" == "latest" ];then
#  bash /usr/local/osbox/bin/update.sh latest $NORELOAD
#else
bash /usr/local/osbox/bin/update.sh
#fi




exit 0
