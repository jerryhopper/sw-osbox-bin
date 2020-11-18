#!/bin/bash




InstallPreRequisites(){
	#
	export LANG=C LC_ALL="en_US.UTF-8"
	export DEBIAN_FRONTEND=noninteractive
	export APT_LISTCHANGES_FRONTEND=none
	sudo apt-get update
	sudo apt-get install -y jq git unzip
	#apt-get install -y docker docker.io avahi-daemon avahi-utils libsodium23 build-essential libzip5 libedit2 libxslt1.1 nmap curl jq wget git unzip sqlite3 php-dev
	#apt-get install -y docker docker.io avahi-daemon avahi-utils libsodium23 build-essential libzip5 libedit2 libxslt1.1 nmap curl jq wget git unzip sqlite3 php-dev


	# remove new user prompt
	rm /root/.not_logged_in_yet
	# change to weak password
	# echo "root:password" | chpasswd

	#/usr/lib/armbian/armbian-firstrun

	# SWOOLE
	#InstallSwoole

	sudo apt-get -y remove build-essential
	sudo apt -y autoremove && apt clean

}



# get os
source /etc/os-release


# packages needed.
case "$VERSION_CODENAME" in
        focal)
            #$PACKAGES="docker avahi-daemon sqlite3 unzip php"
            PACKAGES="docker docker.io avahi-daemon avahi-utils libsodium23 build-essential libzip5 libedit2 libxslt1.1 nmap curl jq wget git unzip sqlite3 php-dev"
            ;;
        buster)
            PACKAGES="docker avahi-daemon"
            exit 1
            ;;
        *)
            echo "Unknown linux version ($VERSION_CODENAME)"
            exit 1
            ;;
esac



# Install packages.
MISSING=$(dpkg --get-selections $PACKAGES 2>&1 | grep -v 'install$' | awk '{ print $6 }')
# Optional check here to skip bothering with apt-get if $MISSING is empty
if [ ! $MISSING=="" ];then
  echo "MISSING='$MISSING'"
  sudo apt-get install $MISSING
  # cleanup
  sudo apt -y autoremove && apt clean
fi


