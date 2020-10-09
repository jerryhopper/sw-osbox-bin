#!/bin/bash

set -e

#MODE='prod'
MODE="dev"


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









# helper fuctions


# installation log
log(){
    echo "$(date) : $1">>/var/osbox-install.log
    echo "$(date) : $1"
}







download_bin_release(){
  log "download_bin_release() - Archive: $OSBOX_BIN_RELEASEARCHIVE"
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
  log "download_core_release() - Archive: $OSBOX_CORE_RELEASEARCHIVE"
  log "Downloading release: $OSBOX_CORE_RELEASEARCHIVEURL"
  wget -nv "${OSBOX_CORE_RELEASEARCHIVEURL}" -O "${OSBOX_CORE_RELEASEARCHIVE}"
  if [ ! -d $OSBOX_CORE_INSTALLDIR ]; then
     log "Creating ${OSBOX_CORE_INSTALLDIR}"
     mkdir ${OSBOX_CORE_INSTALLDIR}
  fi
  # unpack to installation dir.
  log "Extracting archive..."
  tar -xf ${OSBOX_CORE_RELEASEARCHIVE} -C ${OSBOX_CORE_INSTALLDIR} --strip 1
}

download_core_dev(){
  log "download_core_dev() - Git repo: $OSBOX_CORE_REPO"
  log "local directory: ${OSBOX_BIN_GITDIR}/sw-osbox-core"
  # delete previous binaries
  if [ -d ${OSBOX_BIN_GITDIR}/sw-osbox-core ]; then
     log "Removing ${OSBOX_BIN_GITDIR}/sw-osbox-core"
     rm -rf ${OSBOX_BIN_GITDIR}/sw-osbox-core
  fi
  if [ -d ${OSBOX_BIN_INSTALLDIR}project ]; then
      log "Removing ${OSBOX_CORE_INSTALLDIR}"
      rm -rf ${OSBOX_BIN_INSTALLDIR}project
  fi

  log "Cloning repo..."
  git clone -q ${OSBOX_CORE_REPO} ${OSBOX_BIN_GITDIR}sw-osbox-core
  mkdir  ${OSBOX_BIN_INSTALLDIR}project

  # create symbolic links to the gitrepo.
  ln -s  ${OSBOX_BIN_GITDIR}sw-osbox-core ${OSBOX_BIN_INSTALLDIR}project/sw-osbox-core
}


download_bin_dev() {
  log "download_bin_dev() - Git repo: $OSBOX_BIN_REPO"
  log "local directory: ${OSBOX_BIN_GITDIR}sw-osbox-bin"

  # delete previous binaries
  if [ -d ${OSBOX_BIN_GITDIR}/sw-osbox-bin ]; then
     log "Removing  ${OSBOX_BIN_GITDIR}/sw-osbox-bin"
     rm -rf ${OSBOX_BIN_GITDIR}/sw-osbox-bin
  fi
  if [ -d $OSBOX_BIN_INSTALLDIR ]; then
     log "Removing  $OSBOX_BIN_INSTALLDIR"
     rm -rf $OSBOX_BIN_INSTALLDIR
  fi
  log "Cloning repo..."
  git clone -q ${OSBOX_BIN_REPO} ${OSBOX_BIN_GITDIR}sw-osbox-bin
  mkdir -p $OSBOX_BIN_INSTALLDIR

  # create symbolic links.
  log "Creating symlinks.."
  # files
  ln -s ${OSBOX_BIN_GITDIR}sw-osbox-bin/osbox ${OSBOX_BIN_INSTALLDIR}osbox
  ln -s ${OSBOX_BIN_GITDIR}sw-osbox-bin/osbox-boot ${OSBOX_BIN_INSTALLDIR}osbox-boot
  ln -s ${OSBOX_BIN_GITDIR}sw-osbox-bin/osbox-installer-service ${OSBOX_BIN_INSTALLDIR}osbox-installer-service

  # directories
  ln -s ${OSBOX_BIN_GITDIR}sw-osbox-bin/lib ${OSBOX_BIN_INSTALLDIR}lib
  ln -s ${OSBOX_BIN_GITDIR}sw-osbox-bin/bin ${OSBOX_BIN_INSTALLDIR}bin
  ln -s ${OSBOX_BIN_GITDIR}sw-osbox-bin/extra ${OSBOX_BIN_INSTALLDIR}extra

  log "local installer script : ${OSBOX_BIN_INSTALLDIR}extra/install.sh"

}






# helper fuctions

# permissions
setpermissions() {
  log "Set permissions.."
  chmod +x ${OSBOX_BIN_INSTALLDIR}osbox
  chmod +x ${OSBOX_BIN_INSTALLDIR}osbox-boot
  #chmod +x ${OSBOX_BIN_INSTALLDIR}osbox-scheduler
  chmod +x ${OSBOX_BIN_INSTALLDIR}osbox-installer-service
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
  exit 1
fi
if [ ! -f /boot/dietpi/.version ]; then
  log "FATAL: Dietpi version not found!"
  exit 1
fi

source /boot/dietpi/.installed
source /boot/dietpi/.version





# present some info...
echo "OsBox installation script"
echo "---------------------------"
echo "detected hardware: $G_HW_MODEL_NAME"
echo "installation modus: $MODE"
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

if is_command "sqlite3"; then
  echo " X - Sqlite3 available"
else
  echo " O - Sqlite3 not available"
fi
echo " "
sleep 2




if ! is_command "curl"; then
  log "Curl is not available, installing..."
  apt install -y curl
fi

if ! is_command "wget"; then
  log "Wget is not available, installing..."
  apt install -y wget
fi

if ! is_command "jq"; then
  log "jq is not available, installing..."
  apt install -y jq
fi


#if [ "$MODE" = "dev" ]; then
#  echo "Development mode!"
if ! is_command "git"; then
    log "Error. git is not available."
    #log "Trying to install git. You might have to run the installer again."
    /boot/dietpi/dietpi-software install 17 --unattended
    #exit
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
if [ "$MODE" = "dev" ]; then
    log "$MODE installation started."
    download_bin_dev
    download_core_dev
    touch /etc/osbox/dev
else
    log "$MODE installation started."
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


if [ -f /var/lib/dietpi/postboot.d/osbox-boot ]; then
  rm -rf /var/lib/dietpi/postboot.d/osbox-boot
fi





log "Configuring osbox-installer service."
if [ -f /etc/systemd/system/osbox-installer.service ]; then
  rm -f /etc/systemd/system/osbox-installer.service
fi

echo "[Unit]">/etc/systemd/system/osbox-installer.service
echo "Description=osbox-installer-service">>/etc/systemd/system/osbox-installer.service
echo "After=network.target">>/etc/systemd/system/osbox-installer.service
echo "StartLimitIntervalSec=0">>/etc/systemd/system/osbox-installer.service
echo "">>/etc/systemd/system/osbox-installer.service
echo "[Service]">>/etc/systemd/system/osbox-installer.service
echo "Type=forking">>/etc/systemd/system/osbox-installer.service
echo "Restart=always">>/etc/systemd/system/osbox-installer.service
echo "RestartSec=10">>/etc/systemd/system/osbox-installer.service
echo "User=root">>/etc/systemd/system/osbox-installer.service
echo "ExecStart=/usr/local/osbox/osbox-installer-service">>/etc/systemd/system/osbox-installer.service
echo "TasksMax=100">>/etc/systemd/system/osbox-installer.service
echo "[Install]">>/etc/systemd/system/osbox-installer.service
echo "WantedBy=multi-user.target">>/etc/systemd/system/osbox-installer.service


systemctl enable osbox-installer

