#!/bin/bash



# helper fuctions
SCRIPT_FILENAME="install.sh "
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


log "Installation script sw-osbox-bin"


chmod +x /usr/local/osbox/osbox


log "Adding osbox user"
useradd -m -c "osbox user account" osbox


exit


cd /home/osbox

mkdir /etc/osbox
mkdir /var/osbox
download_bin_dev
download_core_dev
log "create_database"
create_database
osbox installservice





#  is swoole available
#  is docker available
#  is avahi available

















set -e

#MODE='prod'
OSBOX_INSTALLMODE="dev"
OSBOX_BIN_USR="osbox"


OSBOX_BIN_GITREPO_URL="https://github.com/jerryhopper/sw-osbox-bin"

OSBOX_BIN_RELEASENAME="$(curl -s https://api.github.com/repos/jerryhopper/sw-osbox-bin/releases/latest|grep "\"name\":"| cut -d '"' -f 4)"

OSBOX_BIN_REPO="${OSBOX_BIN_GITREPO_URL}.git"
OSBOX_BIN_RELEASEARCHIVE="${OSBOX_BIN_RELEASENAME}.tar.gz"





OSBOX_CORE_GITREPO_URL="https://github.com/jerryhopper/sw-osbox-core"
OSBOX_CORE_RELEASENAME="$(curl -s https://api.github.com/repos/jerryhopper/sw-osbox-core/releases/latest|grep "\"name\":"| cut -d '"' -f 4)"
OSBOX_CORE_RELEASENAME="v0.1.1"

OSBOX_CORE_REPO="${OSBOX_CORE_GITREPO_URL}.git"
OSBOX_CORE_RELEASEARCHIVE="${OSBOX_CORE_RELEASENAME}.tar.gz"




#OSBOX_CORE_GITDIR="/home/${OSBOX_BIN_USR}/.${OSBOX_BIN_USR}/"
OSBOX_CORE_INSTALLDIR="/usr/local/${OSBOX_BIN_USR}/project/"



# variable construction
OSBOX_ETC="/etc/${OSBOX_BIN_USR}"


OSBOX_BIN_GITDIR="/home/${OSBOX_BIN_USR}/.${OSBOX_BIN_USR}/"
OSBOX_BIN_INSTALLDIR="/usr/local/${OSBOX_BIN_USR}/"
OSBOX_BIN_RELEASEARCHIVEURL="${OSBOX_BIN_GITREPO_URL}/archive/${OSBOX_BIN_RELEASEARCHIVE}"




package_installed(){
  dpkg -s $1 > /dev/null 2>&1
}
require_packages(){
  if ! package_installed "$1"; then
    PACKAGES+="$1 ";
    echo "Package $1 missing."
  fi
}



# helper fuctions
SCRIPT_FILENAME="install.sh "
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







download_bin_release(){
  #log "download_bin_release() - Archive: $OSBOX_BIN_RELEASEARCHIVE"
  log "Downloading release: $OSBOX_BIN_RELEASEARCHIVEURL"
  wget -nv "${OSBOX_BIN_RELEASEARCHIVEURL}" -O "${OSBOX_BIN_RELEASEARCHIVE}"

  if [ ! -d $OSBOX_BIN_INSTALLDIR ]; then
     log "Creating: ${OSBOX_BIN_INSTALLDIR}"
     mkdir ${OSBOX_BIN_INSTALLDIR}
  fi
  # unpack to installation dir.
  log "Extracting archive..."
  tar -xf ${OSBOX_BIN_RELEASEARCHIVE} -C ${OSBOX_BIN_INSTALLDIR} --strip 1
}


download_core_release(){
  #log "download_core_release() - Archive: $OSBOX_CORE_RELEASEARCHIVE"
  #log "Downloading release: $OSBOX_CORE_RELEASEARCHIVEURL"
  wget -nv "${OSBOX_CORE_RELEASEARCHIVEURL}" -O "${OSBOX_CORE_RELEASEARCHIVE}"
  if [ ! -d $OSBOX_CORE_INSTALLDIR ]; then
     #log "Creating ${OSBOX_CORE_INSTALLDIR}"
     mkdir ${OSBOX_CORE_INSTALLDIR}
  fi
  # unpack to installation dir.
  log "Extracting archive..."
  tar -xf ${OSBOX_CORE_RELEASEARCHIVE} -C ${OSBOX_CORE_INSTALLDIR} --strip 1
}

download_core_dev(){
  #log "download_core_dev() - Git repo: $OSBOX_CORE_REPO"
  #log "local directory: ${OSBOX_BIN_GITDIR}/sw-osbox-core"
  # delete previous binaries
  if [ -d ${OSBOX_BIN_GITDIR}/sw-osbox-core ]; then
     #log "Removing ${OSBOX_BIN_GITDIR}/sw-osbox-core"
     rm -rf ${OSBOX_BIN_GITDIR}/sw-osbox-core
  fi
  if [ -d ${OSBOX_BIN_INSTALLDIR}project ]; then
      #log "Removing ${OSBOX_CORE_INSTALLDIR}"
      rm -rf ${OSBOX_BIN_INSTALLDIR}project
  fi

  #log "Cloning repo..."
  git clone -q ${OSBOX_CORE_REPO} ${OSBOX_BIN_GITDIR}sw-osbox-core
  mkdir  ${OSBOX_BIN_INSTALLDIR}project

  # create symbolic links to the gitrepo.
  ln -s  ${OSBOX_BIN_GITDIR}sw-osbox-core ${OSBOX_BIN_INSTALLDIR}project/sw-osbox-core
}


download_bin_dev() {
  #log "download_bin_dev() - Git repo: $OSBOX_BIN_REPO"
  #log "local directory: ${OSBOX_BIN_GITDIR}sw-osbox-bin"

  # delete previous binaries
  if [ -d ${OSBOX_BIN_GITDIR}/sw-osbox-bin ]; then
     #log "Removing  ${OSBOX_BIN_GITDIR}/sw-osbox-bin"
     rm -rf ${OSBOX_BIN_GITDIR}/sw-osbox-bin
  fi
  if [ -d $OSBOX_BIN_INSTALLDIR ]; then
     #log "Removing  $OSBOX_BIN_INSTALLDIR"
     rm -rf $OSBOX_BIN_INSTALLDIR
  fi
  #log "Cloning repo..."
  git clone -q ${OSBOX_BIN_REPO} ${OSBOX_BIN_GITDIR}sw-osbox-bin
  mkdir -p $OSBOX_BIN_INSTALLDIR

  # create symbolic links.
  #log "Creating symlinks.."
  # files
  ln -s ${OSBOX_BIN_GITDIR}sw-osbox-bin/osbox ${OSBOX_BIN_INSTALLDIR}osbox
  #ln -s ${OSBOX_BIN_GITDIR}sw-osbox-bin/osbox-boot ${OSBOX_BIN_INSTALLDIR}osbox-boot
  ln -s ${OSBOX_BIN_GITDIR}sw-osbox-bin/osbox-installer-service ${OSBOX_BIN_INSTALLDIR}osbox-installer-service
  ln -s ${OSBOX_BIN_GITDIR}sw-osbox-bin/osbox-updater-service ${OSBOX_BIN_INSTALLDIR}osbox-updater-service


  # directories
  ln -s ${OSBOX_BIN_GITDIR}sw-osbox-bin/lib ${OSBOX_BIN_INSTALLDIR}lib
  ln -s ${OSBOX_BIN_GITDIR}sw-osbox-bin/bin ${OSBOX_BIN_INSTALLDIR}bin
  ln -s ${OSBOX_BIN_GITDIR}sw-osbox-bin/extra ${OSBOX_BIN_INSTALLDIR}extra

  #log "local installer script : ${OSBOX_BIN_INSTALLDIR}extra/install.sh"

}


save_prefs(){
  echo "saving prefs..."

}



# helper fuctions

# permissions
setpermissions() {
  log "Set permissions.."
  chmod +x ${OSBOX_BIN_INSTALLDIR}osbox
  #chmod +x ${OSBOX_BIN_INSTALLDIR}osbox-boot
  #chmod +x ${OSBOX_BIN_INSTALLDIR}osbox-scheduler
  chmod +x ${OSBOX_BIN_INSTALLDIR}osbox-installer-service
  chmod +x ${OSBOX_BIN_INSTALLDIR}osbox-updater-service
  chmod +x ${OSBOX_BIN_INSTALLDIR}bin/listen.sh

  #chmod +x ${OSBOX_BIN_INSTALLDIR}osbox-service
  #chmod +x ${OSBOX_BIN_INSTALLDIR}osbox-update
}


# is_command function
is_command() {
    # Checks for existence of string passed in as only function argument.
    # Exit value of 0 when exists, 1 if not exists. Value is the result
    # of the `command` shell built-in call.
    local check_command="$1"
    command -v "${check_command}" >/dev/null 2>&1
}


create_database(){
  # check if sqlite3 db exists.
  #
  #  /host/etc/osbox/master.db
  #  /host/etc/osbox/osbox.db
  if [ ! -d /etc/osbox ]; then
    mkdir -p /etc/osbox
    touch /etc/osbox/dev
  fi

  if [ ! -f /etc/osbox/osbox.db ];then
    touch /etc/osbox/osbox.db
    sqlite3 -batch /etc/osbox/osbox.db "CREATE table installog (id INTEGER PRIMARY KEY,Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,f TEXT);"
    sqlite3 -batch /etc/osbox/osbox.db "insert INTO installog ( f ) VALUES( 'osbox.db created' );"


  fi

}




log "$(date) : Start "

# Required functions.
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

if [ ! -f /boot/dietpi/.installed ]; then
  log "FATAL: Dietpi not installed!"
  #  exit 1
fi
if [ ! -f /boot/dietpi/.version ]; then
  log "FATAL: Dietpi version not found!"
  #  exit 1
fi

#source /boot/dietpi/.installed
#source /boot/dietpi/.version



# present some info...
echo "OsBox installation script"
echo "---------------------------"
echo "detected hardware: $G_HW_MODEL_NAME"
echo "installation modus: $OSBOX_INSTALLMODE"
echo " "
echo "Checking for requirements."
echo " "

if is_command "curl"; then
  echo " X - Curl available"
else
  echo " O - Curl not available"
fi

if is_command "wget"; then
  echo " X - Wget available"
else
  echo " O - Wget not available"
fi

if is_command "git"; then
  echo " X - Git available"
else
  echo " O - Git not available"
fi


if is_command "docker"; then
  echo " X - Docker available"
else
  echo " O - Docker not available"
fi

if is_command "avahi-daemon"; then
  echo " X - Avahi-daemon available"
else
  echo " O - Avahi-daemon not available"
fi



#if [ "$MODE" = "dev" ]; then
#  echo "Development mode!"
if ! is_command "git"; then
    echo " O - Git not available"
    #exit
fi

echo " "
sleep 2


PACKAGES=""
require_packages "git"
require_packages "docker.io"
require_packages "sqlite3"
require_packages "avahi-utils"
require_packages "libsodium23"
require_packages "libgd3"
require_packages "libzip5"
require_packages "libedit2"
require_packages "libxslt1.1"
require_packages "nmap"
require_packages "curl"
require_packages "jq"
require_packages "wget"

#echo $PACKAGES

if [[ "$PACKAGES" == "" ]] ; then
   echo "ok."
else
   apt-get -y install $PACKAGES
fi

if is_command "sqlite3"; then
  echo " X - Sqlite3 available"
  create_database
else
  echo " O - Sqlite3 not available"
  #87 = sqlite
  #/boot/dietpi/dietpi-software install 87 --unattended
  create_database
fi

#fi
#
# Osbox installation script.
#






#log "Osbox installation started.  Architecture: $(uname -m)"


# check if there is a existing installation.
if [ -d /etc/osbox ]; then
  log "Existing installation found."
else
  mkdir /etc/osbox
fi
# check if there is a existing installation.
if [ -d /var/osbox ]; then
  rm -rf /var/osbox
  mkdir /var/osbox

else
  mkdir /var/osbox
fi

if is_command "docker"; then
  log "Docker is available"
  if [ "$(docker ps -a|grep osbox-core)" ]; then
    docker stop osbox-core
    log "stopping container osbox-core"
    #docker rm osbox-core
  else
    log "container osbox-core is not available"
  fi
else
  log "Docker is not available"
fi

echo " "
# Development or production install.
if [ "$OSBOX_INSTALLMODE" = "dev" ]; then
    log "$OSBOX_INSTALLMODE installation started."
    download_bin_dev
    download_core_dev
    touch /etc/osbox/dev
else
    log "$OSBOX_INSTALLMODE installation started."
    download_bin_release
    download_core_dev
fi

# set permissions
setpermissions



if [ -f /sbin/osbox ]; then
  rm -rf /sbin/osbox
fi
ln -s ${OSBOX_BIN_INSTALLDIR}osbox /sbin/osbox
chmod +x /sbin/osbox



log "Configuring osbox-installer service."
if [ -f /etc/systemd/system/osbox-installer.service ]; then
  rm -f /etc/systemd/system/osbox-installer.service
fi
ln -s ${OSBOX_BIN_INSTALLDIR}lib/systemd/osbox-installer.service /etc/systemd/system/osbox-installer.service

systemctl daemon-reload
systemctl enable osbox-installer
systemctl start osbox-installer


log "Finished! "
exit 0
