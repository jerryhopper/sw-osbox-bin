#!/bin/bash

#
# Osbox installation script.
#


# Required functions.

# Root check
if [[ ! $EUID -eq 0 ]];then
  if [[ -x "$(command -v sudo)" ]]; then
    exec sudo bash "$0" "$@"
    exit $?
  else
    echo -e "  ${CROSS} sudo is needed to run the installer.  Please run this script as root or install sudo."
    exit 1
  fi
fi

# helper fuctions
# is_command function
is_command() {
    # Checks for existence of string passed in as only function argument.
    # Exit value of 0 when exists, 1 if not exists. Value is the result
    # of the `command` shell built-in call.
    local check_command="$1"

    command -v "${check_command}" >/dev/null 2>&1
}

# installation log
log(){
    echo "$(date) : $1">>./install.log
}

log "Osbox installation started."

# Software requirements.

CURDIR=$PWD


architecture=$(uname -m)


if [ ! -d "./lib/arch/$architecture" ]; then
  echo "invalid platform  $(uname -m)"
  #  exit;
fi

# remove osbox file.
if [ -d /home/osbox/.osbox ]; then
  rm -rf /home/osbox/.osbox
fi

# required stuff
echo "Updating requirements."



# check if dietpi-software command exists.
#if ! -f "/boot/dietpi/dietpi-software" ; then
#    echo "FATAL Operating System Error. Are you running this on dietpi? "
#    log "FATAL Operating System Error. Are you running this on dietpi? "
#    exit
#fi

# check if git command exists.
if ! is_command git ; then
    echo "Error. git is not available."
    echo "Trying to install git. You might have to run the installer again."
    log "Trying to install git. You might have to run the installer again."
    /boot/dietpi/dietpi-software install 17 --unattended
    #exit
fi



# check if avahi-daemon command exists.
if ! is_command avahi-daemon ; then
    echo "Error. avahi-daemon is not available."
    echo "Trying to install avahi-daemon."
    log "Trying to install avahi-daemon."
    /boot/dietpi/dietpi-software install 152 --unattended
    apt-get install -y avahi-utils libsodium23 libgd3 libzip4 libedit2 libxslt1.1
    #exit
fi


# check if avahi-daemon command exists.
if ! is_command docker ; then
    echo "Error. docker is not available."
    echo "Trying to install docker"
    log "Trying to install docker."
    /boot/dietpi/dietpi-software install 162 --unattended
    #exit
fi


#hostnamectl set-hostname osbox

# adduser
echo "Adding osbox user."
if id -u osbox >/dev/null 2>&1; then
    echo "Skipping, user already exists."
    log "Osbox user already exists."
else
    useradd -m osbox
    log "Adding osbox user."
fi



# add to sudoers
if [ -f /etc/sudoers.d/osbox ]; then
   rm -f /etc/sudoers.d/osbox
fi
echo "osbox ALL=NOPASSWD: /usr/local/osbox/osbox">/etc/sudoers.d/osbox




# check if there is a existing installation.
if [ -d /etc/osbox ]; then
  echo "Existing installation found."
  log "Existing installation found."
else
  mkdir /etc/osbox
fi




exit 1

#git clone https://github.com/jerryhopper/sw-osbox-bin.git /home/osbox/.osbox/sw-osbox-bin
#git clone https://github.com/jerryhopper/sw-osbox-core.git /home/osbox/.osbox/sw-osbox-core









# check if osbox directory exists, and delete it.
#if [ -d /usr/local/osbox ]; then
#  log "Removing /usr/local/osbox directory."
#  rm -rf /usr/local/osbox
#fi

# make the directories
#log "Creating directories"
#mkdir /usr/local/osbox
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





# copy avahi configuration
echo "Configuring avahi."
log "Configuring avahi."
if [ -f /etc/avahi/services/osbox.service ]; then
  rm -f /etc/avahi/services/osbox.service
fi
cp ./lib/avahi/osbox.service /etc/avahi/services/osbox.service
systemctl restart avahi-daemon

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