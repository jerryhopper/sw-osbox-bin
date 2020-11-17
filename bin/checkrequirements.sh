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
#exitcode="1"
if [ $exitcode == "1" ] ;then
   log "requirements not met, aborting"
   #InstallPreRequisites
   #exit 1
fi
