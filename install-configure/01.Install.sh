#!/usr/bin/env bash

# Run this as bash 01.Install.sh

# Configs
GEM_TIMEZONE=YOUR-TIMEZONE
GEM_USERNAME=YOUR-NAME
GEM_PASSWORD=YOUR-PASSWORD
GEM_HOSTNAME=YOUR-HOSTNAME
GEM_WIFI_SSID=YOUR-SSID
GEM_WIFI_KEY=YOUR-SSID-PASSWORD

clear
echo -e "\e[1;36m> This will update the base system, install some tools and apps and create a new user $GEM_USERNAME\e[0m"
echo "> Disable ancient repos"
echo "> Update APT repos and install apt-transport-https"
echo "> Purge VLC before installing again later (causes upgrading error)"
echo "> Upgrade the system, this one will fail because of the libreOffice nonsense (causes upgrading error)"
echo "> Repair libreOffice"
echo "> Update APT repos and install some tools"
echo "> Update APT repos and install some apps"
echo "> Upgrade the system - system wide upgrade"
echo "> Set Timezone as $GEM_TIMEZONE"
echo "> Set Locale as en_GB.UTF-8"
echo "> Create a new user called $GEM_USERNAME"
echo "> Change the hostname to $GEM_HOSTNAME /etc/hostname needs setting first"
echo "> Enable avahi"
echo "> Configure wpa_supplicant for automatic login to $GEM_WIFI_SSID"
echo "> Symlink the config into -wlan0.conf"
echo "> Configure wlan0 interface"
echo "> Finally, tidy everything up"
sleep 3;

# Try the default password to sudo up.
echo $GEM_PASSWORD | sudo -S true > /dev/null 2>&1

# Disable ancient repos
echo -e "\e[1;33mDisable ancient repos...\e[0m"
echo $GEM_PASSWORD | sudo sed -i 's/deb/#deb/' /etc/apt/sources.list.d/multistrap-gemian.list

# Update APT repos and install apt-transport-https
echo -e "\e[1;33mUpdate APT repos and install apt-transport-https...\e[0m"
echo $GEM_PASSWORD | sudo apt-get update -qq
echo $GEM_PASSWORD | sudo apt-get install apt-transport-https

# Purge VLC before installing again later (causes upgrading error)
echo -e "\e[1;33mPurge VLC before installing again later (causes upgrading error)...\e[0m"
echo $GEM_PASSWORD | sudo apt-get -yq purge --auto-remove vlc

# Upgrade the system, this one will fail because of the libreOffice nonsense (causes upgrading error)
echo -e "\e[1;33mUpgrade the system, this one will fail because of the libreOffice nonsense (causes upgrading error)...\e[0m"
echo $GEM_PASSWORD | sudo apt-get -y upgrade

# Repair libreOffice
echo -e "\e[1;33mRepair libreOffice...\e[0m"
echo $GEM_PASSWORD | sudo dpkg-divert --remove /usr/lib/libreoffice/share/basic/dialog.xlc
echo $GEM_PASSWORD | sudo dpkg-divert --remove /usr/lib/libreoffice/share/basic/script.xlc
echo $GEM_PASSWORD | sudo dpkg -i --force-overwrite /var/cache/apt/archives/libreoffice*
echo $GEM_PASSWORD | sudo apt-get install -f

# Update APT repos and install some tools
echo -e "\e[1;33mUpdate APT repos and install some tools...\e[0m"
echo $GEM_PASSWORD | sudo -S apt-get update -qq
echo $GEM_PASSWORD | sudo -S apt-get -y install -y \
    aptitude \
    openssh-client \
    openssh-server \
    avahi-daemon \
    curl \
    wget \
    git \
    htop \
    iproute2 \
    systemd-sysv \
    locales \
    iputils-ping \
    usbutils \
    wireless-tools \
    jq \
    gawk \
    ssh \
    sshfs \
    screen \
    tmux \
    mc \
    multitail \
    locate \
    vsftpd \
    android-tools-adb \
    android-tools-fastboot \
    build-essential \
    python3 \
    software-properties-common \
    compton \
    gdebi

# Update APT repos and install some apps
echo -e "\e[1;33mUpdate APT repos and install some apps...\e[0m"
echo $GEM_PASSWORD | sudo -S apt-get update -qq
echo $GEM_PASSWORD | sudo -S apt-get -y install -y \
    geany \
    terminator \
    conky-all \
    bleachbit \
    filezilla \
    thunderbird \
    gthumb \
    gimp \
    vlc \
    wireshark \
    aircrack-ng \
    plank \
    menulibre \
    thunar \
    audacious

# Upgrade the system - system wide upgrade
echo -e "\e[1;33mUpgrade the system - system wide upgrade...\e[0m"
echo $GEM_PASSWORD | sudo apt-get -y upgrade

# Set Timezone as $GEM_TIMEZONE
echo -e "\e[1;33mSet Timezone as $GEM_TIMEZONE...\e[0m"
echo $GEM_PASSWORD | sudo ln -fs /usr/share/zoneinfo/$GEM_TIMEZONE /etc/localtime
echo $GEM_PASSWORD | sudo dpkg-reconfigure -f noninteractive tzdata

# Set Locale as en_GB.UTF-8
echo -e "\e[1;33mSet Locale as en_GB.UTF-8...\e[0m"
echo 'LANG="en_GB.UTF-8"' | sudo tee /etc/default/locale
echo $GEM_PASSWORD | sudo sed -i -e "s/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/" /etc/locale.gen
echo $GEM_PASSWORD | sudo -S dpkg-reconfigure --frontend=noninteractive locales
echo $GEM_PASSWORD | sudo -S update-locale LANG=en_GB.UTF-8

# Create a new user called $GEM_USERNAME
echo -e "\e[1;33mCreate a new user called $GEM_USERNAME...\e[0m"
if [ ! -d  /home/$GEM_USERNAME ]; then
    echo $GEM_PASSWORD | sudo useradd \
        $GEM_USERNAME \
        -m \
        -s /bin/bash \
        -u 100001 \
        -p $(openssl passwd -1 $GEM_PASSWORD)
    # Make the new user a sudoer
    echo $GEM_PASSWORD | sudo usermod -aG sudo $GEM_USERNAME
fi

# Change the hostname to $GEM_HOSTNAME /etc/hostname needs setting first
echo -e "\e[1;33mChange the hostname to $GEM_HOSTNAME /etc/hostname needs setting first...\e[0m"
echo -e $GEM_HOSTNAME | sudo tee /etc/hostname
echo -e "127.0.0.1\t$GEM_HOSTNAME" | sudo tee -a /etc/hosts
echo $GEM_PASSWORD | sudo invoke-rc.d hostname.sh start
echo $GEM_PASSWORD | sudo invoke-rc.d networking force-reload

# Enable avahi
echo -e "\e[1;33mEnable avahi...\e[0m"
echo $GEM_PASSWORD | sudo systemctl unmask avahi-daemon
echo $GEM_PASSWORD | sudo systemctl enable avahi-daemon

# Configure wpa_supplicant for automatic login to $GEM_WIFI_SSID
echo -e "\e[1;33mConfigure wpa_supplicant for automatic login to $GEM_WIFI_SSID...\e[0m"
echo "ctrl_interface=/run/wpa_supplicant" | sudo tee /etc/wpa_supplicant/wpa_supplicant.conf
echo "update_config=1" | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf
echo "ap_scan=1" | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf
echo "network={" | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf
echo "	ssid=$GEM_WIFI_SSID" | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf
echo "	psk=$GEM_WIFI_KEY" | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf
echo "}" | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf

if [ -f /etc/wpa_supplicant/wpa_supplicant.conf ]; then
    echo "\e[32mWritten to /etc/wpa_supplicant/wpa_supplicant.conf OK\e[0m"
else
    echo "\e[31mFailed to write to /etc/wpa_supplicant/wpa_supplicant.conf\e[0m"
fi

# Symlink the config into -wlan0.conf
echo -e "\e[1;33mSymlink the config into -wlan0.conf\e[0m"
if [ ! -f /etc/wpa_supplicant/wpa_supplicant-wlan0.conf ]; then
    echo $GEM_PASSWORD | sudo ln -s /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
fi

# Configure wlan0 interface
echo -e "\e[1;33mConfigure wlan0 interface\e[0m"
echo -e "allow-hotplug wlan0\niface wlan0 inet dhcp\n\twpa-conf /etc/wpa_supplicant/wpa_supplicant.conf" | sudo tee /etc/network/interfaces.d/wlan0

# Finally, tidy everything up
echo -e "\e[1;33mFinally, tidy everything up...\e[0m"
sudo apt-get update -qq && sudo apt-get upgrade && sudo apt-get remove && sudo apt-get clean && sudo apt-get autoremove && sudo apt-get autoclean

echo ""
echo -e "\e[1;36mDONE...\e[0m"
sleep 3;

clear
echo -e "\e[1;36m> This will check the configurations and apps have been installed correctly\e[0m"
echo "> Check the Timezone is set correctly to $GEM_TIMEZONE"
echo "> Check the Locale is set correctly to LANG=en_GB.UTF-8"
echo "> Check the new user $GEM_USERNAME exists"
echo "> Check that new user $GEM_USERNAME has sudo rights"
echo "> Check the hostname is set correctly to $GEM_HOSTNAME"
echo "> Check that /etc/hosts contains the localhost IP and hostname $GEM_HOSTNAME"
echo "> Check that /etc/wpa_supplicant/wpa_supplicant.conf exists"
echo "> Check that /etc/wpa_supplicant/wpa_supplicant.conf contains the new GEM_WIFI_SSID $GEM_WIFI_SSID"
echo "> Check that /etc/wpa_supplicant/wpa_supplicant.conf contains the new GEM_WIFI_KEY $GEM_WIFI_KEY"
echo "> Check that /etc/wpa_supplicant/wpa_supplicant-wlan0.conf exists"
echo "> Check that /etc/network/interfaces.d/wlan0 exists"
sleep 3;

# Try the default password to sudo up.
echo $GEM_PASSWORD | sudo -S true > /dev/null 2>&1

# Check the Timezone is set correctly to $GEM_TIMEZONE
if [[ "$(cat /etc/timezone)" == "$GEM_TIMEZONE" ]]; then
    echo -e "Is the Timezone set to $GEM_TIMEZONE: \e[32mYes\e[0m"
else
    echo -e "Is the Timezone set to $GEM_TIMEZONE: \e[31mNo\e[0m"
fi

# Check the Locale is set correctly to LANG=en_GB.UTF-8
if [[ "$(cat /etc/default/locale)" == "LANG=en_GB.UTF-8" ]]; then
    echo -e "Is the Locale set correctly: \e[32mYes\e[0m"
else
    echo -e "Is the Locale set correctly: \e[31mNo\e[0m"
fi

# Check the new user $GEM_USERNAME exists
if id -u "$GEM_USERNAME" >/dev/null 2>&1; then
    echo -e "Does new user $GEM_USERNAME exist: \e[32mYes\e[0m"
else
    echo -e "Does new user $GEM_USERNAME exist: \e[31mNo\e[0m"
fi

# Check that new user $GEM_USERNAME has sudo rights
if [[ $(groups $GEM_USERNAME) == *sudo* ]]; then
    echo -e "Does new user $GEM_USERNAME have sudo rights: \e[32mYes\e[0m"
else
    echo -e "Does new user $GEM_USERNAME have sudo rights: \e[31mNo\e[0m"
fi

# Check the hostname is set correctly to $GEM_HOSTNAME
if [[ "$(cat /etc/hostname)" == "$GEM_HOSTNAME" ]]; then
    echo -e "Is the hostname set to $GEM_HOSTNAME: \e[32mYes\e[0m"
else
    echo -e "Is the hostname set to $GEM_HOSTNAME: \e[31mNo\e[0m"
fi

# Check that /etc/hosts contains the localhost IP and hostname $GEM_HOSTNAME"
if grep -q "127.0.0.1	gemini" /etc/hosts
then
    echo -e "Does /etc/hosts contain the localhost IP and hostname $GEM_HOSTNAME: \e[32mYes\e[0m"
else
    echo -e "Does /etc/hosts contain the localhost IP and hostname $GEM_HOSTNAME: \e[31mNo\e[0m"
fi

# Check that /etc/wpa_supplicant/wpa_supplicant.conf exists
if [ -f /etc/wpa_supplicant/wpa_supplicant.conf ]; then
    echo -e "Does /etc/wpa_supplicant/wpa_supplicant.conf exist: \e[32mYes\e[0m"
else
    echo -e "Does /etc/wpa_supplicant/wpa_supplicant.conf exist: \e[31mNo\e[0m"
fi

# Check that /etc/wpa_supplicant/wpa_supplicant.conf contains the new GEM_WIFI_SSID $GEM_WIFI_SSID
if grep -q "$GEM_WIFI_SSID" /etc/wpa_supplicant/wpa_supplicant.conf
then
    echo -e "Does the /etc/wpa_supplicant/wpa_supplicant.conf contains the new GEM_WIFI_SSID $GEM_WIFI_SSID: \e[32mYes\e[0m"
else
    echo -e "Does /etc/wpa_supplicant/wpa_supplicant.conf contains the new GEM_WIFI_SSID $GEM_WIFI_SSID: \e[31mNo\e[0m"
fi

# Check that /etc/wpa_supplicant/wpa_supplicant.conf contains the new GEM_WIFI_KEY $GEM_WIFI_KEY
if grep -q "$GEM_WIFI_KEY" /etc/wpa_supplicant/wpa_supplicant.conf
then
    echo -e "Does the /etc/wpa_supplicant/wpa_supplicant.conf contains the new GEM_WIFI_KEY $GEM_WIFI_KEY: \e[32mYes\e[0m"
else
    echo -e "Does /etc/wpa_supplicant/wpa_supplicant.conf contains the new GEM_WIFI_KEY $GEM_WIFI_KEY: \e[31mNo\e[0m"
fi

# Check that /etc/wpa_supplicant/wpa_supplicant-wlan0.conf exists
if [ -f /etc/wpa_supplicant/wpa_supplicant-wlan0.conf ]; then
    echo -e "Does /etc/wpa_supplicant/wpa_supplicant-wlan0.conf exist: \e[32mYes\e[0m"
else
    echo -e "Does /etc/wpa_supplicant/wpa_supplicant-wlan0.conf exist: \e[31mNo\e[0m"
fi

# Check that /etc/network/interfaces.d/wlan0 exists
if [ -f /etc/network/interfaces.d/wlan0 ]; then
    echo -e "Does /etc/network/interfaces.d/wlan0 exist: \e[32mYes\e[0m"
else
    echo -e "Does /etc/network/interfaces.d/wlan0 exist: \e[31mNo\e[0m"
fi

echo ""
echo -e "\e[1;36mDONE...\e[0m"
echo ""
echo -e "\e[31mNeed to reboot and log in as $GEM_USERNAME to finish the configuration\e[0m"
echo ""
