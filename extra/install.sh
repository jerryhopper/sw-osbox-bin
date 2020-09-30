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
    echo "$(date) : $1">>./install.log
    echo "$(date) : $1"
}







download_bin_release(){
  log "Archive: $OSBOX_BIN_RELEASEARCHIVE"
  log "Downloading release: $OSBOX_BIN_RELEASEARCHIVEURL"
  wget -nv "${OSBOX_BIN_RELEASEARCHIVEURL}" -O "${OSBOX_BIN_RELEASEARCHIVE}"
  log "Extracting archive..."
  if [ ! -d $OSBOX_BIN_INSTALLDIR ]; then
     mkdir ${OSBOX_BIN_INSTALLDIR}
  fi
  # unpack to installation dir.
  tar -xf ${OSBOX_BIN_RELEASEARCHIVE} -C ${OSBOX_BIN_INSTALLDIR} --strip 1
}


download_core_release(){
  log "Archive: $OSBOX_CORE_RELEASEARCHIVE"
  log "Downloading release: $OSBOX_CORE_RELEASEARCHIVEURL"
  wget -nv "${OSBOX_CORE_RELEASEARCHIVEURL}" -O "${OSBOX_CORE_RELEASEARCHIVE}"
  log "Extracting archive..."
  if [ ! -d $OSBOX_CORE_INSTALLDIR ]; then
     mkdir ${OSBOX_CORE_INSTALLDIR}
  fi
  # unpack to installation dir.
  tar -xf ${OSBOX_CORE_RELEASEARCHIVE} -C ${OSBOX_CORE_INSTALLDIR} --strip 1
}

download_core_dev(){
  # delete previous binaries
  if [ -d ${OSBOX_BIN_GITDIR}/sw-osbox-core ]; then
     rm -rf ${OSBOX_BIN_GITDIR}/sw-osbox-core
  fi
  if [ -d ${OSBOX_BIN_INSTALLDIR}project ]; then
      rm -rf ${OSBOX_BIN_INSTALLDIR}project
  fi

  git clone -q ${OSBOX_CORE_REPO} ${OSBOX_BIN_GITDIR}sw-osbox-core
  mkdir  ${OSBOX_BIN_INSTALLDIR}project

  # create symbolic links to the gitrepo.
  ln -s  ${OSBOX_BIN_GITDIR}sw-osbox-core ${OSBOX_BIN_INSTALLDIR}project/sw-osbox-core
}


download_bin_dev() {
  # delete previous binaries
  if [ -d ${OSBOX_BIN_GITDIR}/sw-osbox-bin ]; then
     rm -rf ${OSBOX_BIN_GITDIR}/sw-osbox-bin
  fi
  if [ -d $OSBOX_BIN_INSTALLDIR ]; then
     rm -rf $OSBOX_BIN_INSTALLDIR
  fi

  git clone -q ${OSBOX_BIN_REPO} ${OSBOX_BIN_GITDIR}sw-osbox-bin
  mkdir -p $OSBOX_BIN_INSTALLDIR

  # create symbolic links to the gitrepo.
  ln -s ${OSBOX_BIN_GITDIR}sw-osbox-bin/osbox ${OSBOX_BIN_INSTALLDIR}osbox
  ln -s ${OSBOX_BIN_GITDIR}sw-osbox-bin/osbox-boot ${OSBOX_BIN_INSTALLDIR}osbox-boot
  ln -s ${OSBOX_BIN_GITDIR}sw-osbox-bin/osbox-update ${OSBOX_BIN_INSTALLDIR}osbox-update

  ln -s ${OSBOX_BIN_GITDIR}sw-osbox-bin/lib ${OSBOX_BIN_INSTALLDIR}lib
  ln -s ${OSBOX_BIN_GITDIR}sw-osbox-bin/bin ${OSBOX_BIN_INSTALLDIR}bin

}









# helper fuctions

# permissions
setpermissions() {
  chmod +x ${OSBOX_BIN_INSTALLDIR}osbox
  chmod +x ${OSBOX_BIN_INSTALLDIR}osbox-boot
  chmod +x ${OSBOX_BIN_INSTALLDIR}osbox-scheduler
  chmod +x ${OSBOX_BIN_INSTALLDIR}osbox-service
  chmod +x ${OSBOX_BIN_INSTALLDIR}osbox-update
}

# git installation
requireGit() {
  # check if git command exists.
  if [ ! is_command "git" ]; then
      #echo "Error. git is not available."
      log "Trying to install git. You might have to run the installer again."
      /boot/dietpi/dietpi-software install 17 --unattended
      #exit
  fi

}
# is_command function
is_command() {
    # Checks for existence of string passed in as only function argument.
    # Exit value of 0 when exists, 1 if not exists. Value is the result
    # of the `command` shell built-in call.
    local check_command="$1"
    command -v "${check_command}" >/dev/null 2>&1
}







echo "$(date) : Start ">./install.log

# Required functions.
# Root check
if [[ ! $EUID -eq 0 ]];then
  if [[ -x "$(command -v sudo)" ]]; then
    exec sudo bash "$0" "$@"
    exit $?
  else
    echo -e "   sudo is needed to run the installer.  Please run this script as root or install sudo."
    exit 1
  fi
fi

if [ ! -f /boot/dietpi/.installed ]; then
  echo "FATAL: Dietpi not installed!"
  exit 1
fi
if [ ! -f /boot/dietpi/.version ]; then
  echo "FATAL: Dietpi version not found!"
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

sleep 2


if ! is_command "curl"; then
  echo "Curl is not available, installing..."
  apt install -y curl
fi

if ! is_command "wget"; then
  echo "Wget is not available, installing..."
  apt install -y wget
fi

if ! is_command "jq"; then
  echo "jq is not available, installing..."
  apt install -y jq
fi


if [ "$MODE" = "dev" ]; then
  echo "Development mode!"
  requireGit
fi
#
# Osbox installation script.
#






log "Osbox installation started.  Architecture: $(uname -m)"


# check if there is a existing installation.
if [ -d /etc/osbox ]; then
  log "Existing installation found."
else
  mkdir /etc/osbox
fi


if is_command "docker"; then
  docker stop osbox-core
  docker rm osbox-core
fi

# Development or production install.
if [ "$MODE" = "dev" ]; then
    #requireGit
    download_bin_dev
    download_core_dev
    touch /etc/osbox/dev
else
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
ln -s  ${OSBOX_BIN_INSTALLDIR}osbox-boot /var/lib/dietpi/postboot.d/osbox-boot
chmod +x /var/lib/dietpi/postboot.d/osbox-boot



osbox install

exit 0














































if is_command "osbox"; then
  # run the installer
  osbox install

fi

CURDIR=$PWD






exit 1


# remove osbox file.
if [ -d /home/osbox/.osbox ]; then
  rm -rf /home/osbox/.osbox
fi







if [ ! -d /var/lib/dietpi/postboot.d  ]; then
   echo "Not dietpi? "
   exit 0
fi








# required stuff
echo "Updating requirements."

# check if dietpi-software command exists.
#if ! -f "/boot/dietpi/dietpi-software" ; then
#    echo "FATAL Operating System Error. Are you running this on dietpi? "
#    log "FATAL Operating System Error. Are you running this on dietpi? "
#    exit
#fi











exit 1










echo "Configuring osbox service."
log "Configuring osbox service."
if [ -f /etc/systemd/system/osbox.service ]; then
  rm -f /etc/systemd/system/osbox.service
fi


echo "[Unit]">/etc/systemd/system/osbox.service
echo "Description=OsBox web-service">>/etc/systemd/system/osbox.service
echo "After=network.target">>/etc/systemd/system/osbox.service
echo "StartLimitIntervalSec=0">>/etc/systemd/system/osbox.service
echo "">>/etc/systemd/system/osbox.service
echo "[Service]">>/etc/systemd/system/osbox.service
echo "Type=forking">>/etc/systemd/system/osbox.service
echo "Restart=always">>/etc/systemd/system/osbox.service
echo "RestartSec=10">>/etc/systemd/system/osbox.service
echo "User=root">>/etc/systemd/system/osbox.service
echo "ExecStart=/usr/local/osbox/osbox-service">>/etc/systemd/system/osbox.service
echo "TasksMax=100">>/etc/systemd/system/osbox.service
echo "[Install]">>/etc/systemd/system/osbox.service
echo "WantedBy=multi-user.target">>/etc/systemd/system/osbox.service

systemctl enable osbox



git clone https://github.com/jerryhopper/sw-osbox-bin.git /home/osbox/.osbox/sw-osbox-bin
#git clone https://github.com/jerryhopper/sw-osbox-core.git /home/osbox/.osbox/sw-osbox-core









# check if osbox directory exists, and delete it.
if [ -d /usr/local/osbox ]; then
  log "Removing /usr/local/osbox directory."
  rm -rf /usr/local/osbox
f

# make the directories
log "Creating directories"
mkdir /usr/local/osbox
#mkdir /usr/local/osbox/project

#ln -s /home/osbox/.osbox /usr/local/osbox/project
#ln -s /home/osbox/.osbox/sw-osbox-bin/lib /usr/local/osbox/lib

#bash /home/osbox/.osbox/sw-osbox-bin/osbox-update



























# copy the contents of the archive.
#echo "Installing files."
#log "Installing files."
#cp -r ./lib/etc /
#cp -R /home/osbox/.osbox/sw-osbox-bin/osbox* /usr/local/osbox




# set permissions
#echo "Setting permissions."
#log "Setting permissions."
#chmod +x /usr/local/osbox/osbox
# remove symlink if exists
#if [ -f /bin/osbox ]; then
#  log "removing symlink /bin/osbox"
#  rm -f /bin/osbox
#fi
# make symlink
#log "create symlink /bin/osbox"
#ln -s /usr/local/osbox/osbox /bin/osbox



# set permissions
#log "Set permissions."
#chmod +x /usr/local/osbox/osbox-boot
#chmod +x /usr/local/osbox/osbox-scheduler
#chmod +x /usr/local/osbox/osbox-service
#chmod +x /usr/local/osbox/osbox-update

#chmod +x /usr/local/osbox/bin/osboxd

# set executable bit for composer
#chmod +x /usr/local/osbox/bin/composer.phar




exit 1











#cp -R ./lib /usr/local/osbox
#ln -s /usr/local/osbox/lib/arch/$(uname -m)/bin /usr/local/osbox/bin


# run architecture specific stuff.
bash /usr/local/osbox/bin/install.sh




# set permissions
echo "Setting permissions."
log "Setting permissions."
chmod +x /usr/local/osbox/osbox
# remove symlink if exists
if [ -f /bin/osbox ]; then
  log "removing symlink /bin/osbox"
  rm -f /bin/osbox
fi
# make symlink
log "create symlink /bin/osbox"
ln -s /usr/local/osbox/osbox /bin/osbox



# set permissions
log "Set permissions."
chmod +x /usr/local/osbox/osbox-boot
chmod +x /usr/local/osbox/osbox-scheduler
chmod +x /usr/local/osbox/osbox-service
chmod +x /usr/local/osbox/osbox-update

chmod +x /usr/local/osbox/bin/osboxd

# set executable bit for composer
chmod +x /usr/local/osbox/bin/composer.phar


log "Cloning osbox-core repository"
# get the core files.
cd /usr/local/osbox/project

git clone https://github.com/jerryhopper/sw-osbox-core.git

cd $CURDIR


#  docker run -d --rm -ti --name osbox-core test:latest
#  -v /var/run/docker.sock:/var/run/docker.sock



#echo "CHECK! "
#echo "swoole > "
#PHP_INI_SCAN_DIR=/usr/local/osbox/bin/conf.d /usr/local/osbox/bin/osboxd -c /usr/local/osbox/bin/osboxd.ini --re swoole
#echo " end swoole result < "
echo "--------- "

#echo "CHECK! "
#echo "phar > "
#PHP_INI_SCAN_DIR=/usr/local/osbox/bin/conf.d /usr/local/osbox/bin/osboxd -c /usr/local/osbox/bin/osboxd.ini --re phar
#echo " end phar result < "
#echo "--------- "


#PHP_INI_SCAN_DIR=/usr/local/osbox/bin/conf.d /usr/local/osbox/bin/osboxd -c /usr/local/osbox/bin/osboxd.ini /usr/local/osbox/bin/composer.phar












echo "Satisfying osbox-core requirements."
PHP_INI_SCAN_DIR=/usr/local/osbox/bin/conf.d /usr/local/osbox/bin/osboxd -c /usr/local/osbox/bin/osboxd.ini /usr/local/osbox/bin/composer.phar install --working-dir=/usr/local/osbox/project/sw-osbox-core

#PHP_INI_SCAN_DIR=/usr/local/osbox/bin/conf.d
#/usr/local/osbox/bin/osboxd -c /usr/local/osbox/bin/osboxd.ini /usr/local/osbox/bin/composer.phar --working-dir=/usr/local/osbox/project/sw-osbox-core install


if [ ! -f /etc/osbox/db/osbox.db ]; then
    touch /etc/osbox/db/osbox.db
    chown osbox:osbox /etc/osbox/db/osbox.db
    chmod a+w /etc/osbox/db/osbox.db
    chmod a+w /etc/osbox/db
fi






# copy systemd config & enable start on boot
echo "Configuring osbox service."
log "Configuring osbox service."
if [ -f /etc/systemd/system/osbox.service ]; then
  rm -f /etc/systemd/system/osbox.service
fi
cp ./lib/systemd/osbox.service /etc/systemd/system/osbox.service
systemctl enable osbox


# copy systemd config & enable start on boot
echo "Configuring osbox-scheduler service."
log "Configuring osbox-scheduler service."
if [ -f /etc/systemd/system/osbox-scheduler.service ]; then
  rm -f /etc/systemd/system/osbox-scheduler.service
fi
cp ./lib/systemd/osbox-scheduler.service /etc/systemd/system/osbox-scheduler.service
systemctl enable osbox-scheduler

echo "preinstall,10,Pre-installation state">/etc/osbox/setup.state

echo "Done!"
echo " "
echo "The Webservice is available @ http://osbox.local"
#echo "rebooting in 5 seconds. "
#sleep 5

#shutdown -r now

}
