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

# check if dietpi-software command exists.
if ! is_command dietpi-software ; then
    echo "FATAL Operating System Error. Are you running this on dietpi? "
    log "FATAL Operating System Error. Are you running this on dietpi? "
    exit
fi

# check if git command exists.
if ! is_command git ; then
    echo "Error. git is not available."
    echo "Trying to install git. You might have to run the installer again."
    log "Trying to install git. You might have to run the installer again."

    dietpi-software install 17
    #exit
fi



# check if avahi-daemon command exists.
if ! is_command avahi-daemon ; then
    echo "Error. avahi-daemon is not available."
    echo "Trying to install avahi-daemon."
    log "Trying to install avahi-daemon."
    dietpi-software install 152
    #exit
fi

# check if avahi-daemon command exists.
if ! is_command avahi-browse ; then
    echo "Error. avahi-browse is not available."
    echo "Trying to install avahi-browse."
    log "Trying to install avahi-browse."
    apt-get install -y avahi-utils
    #exit
fi




# adduser
echo "Adding osbox user."
if id -u osbox >/dev/null 2>&1; then
    echo "Skipping, user already exists."
    log "Osbox user already exists."
else
    sudo useradd osbox
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

# check if osbox directory exists, and delete it.
if [ -d /usr/local/osbox ]; then
  log "Removing /usr/local/osbox directory."
  rn -rf /usr/local/osbox
fi

# make the directories
log "Creating directories"
mkdir /usr/local/osbox
mkdir /usr/local/osbox/project


# copy the contents of the archive.
echo "Installing files."
log "Installing files."
cp -R ./osbox-* /usr/local/osbox

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
# symlink php for composer
ln -s /usr/local/osbox/bin/composer.phar /usr/local/osbox/bin/php

log "Cloning osbox-core repository"
# get the core files.
cd /usr/local/osbox/project

git clone https://github.com/jerryhopper/sw-osbox-core.git

cd /usr/local/osbox









# copy avahi configuration
echo "Configuring avahi."
log "Configuring avahi."
if [ -f /etc/avahi/services/osbox.service ]; then
  rm -f /etc/avahi/services/osbox.service
fi
cp ./lib/avahi/osbox.service /etc/avahi/services/osbox.service


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

echo "Done!"
#shutdown -r now
