#!/usr/bin/env bash

# Run this as bash 02.Configure.sh

# Configs
GEM_TIMEZONE=YOUR-TIMEZONE
GEM_USERNAME=YOUR-NAME
GEM_PASSWORD=YOUR-PASSWORD
GEM_HOSTNAME=YOUR-HOSTNAME
GEM_WIFI_SSID=YOUR-SSID
GEM_WIFI_KEY=YOUR-SSID-PASSWORD

clear
echo -e "\e[1;36m> This will add scripts, configure existing apps and add some new ones for $GEM_USERNAME\e[0m"
echo "> Configure wireshark"
echo "> Make the Terminal colourful"
echo "> Delete the gemini user"
echo "> Remove some directories"
echo "> Add some directories"
echo "> Add and configure the .ssh directory"
echo "> Populate the .ssh directory"
echo "> Add some scripts"
echo "> Install Arduino from backup and configure"
echo "> Install VNC from backup"
echo "> Configure Conky & Compton"
echo "> Autohide the bottom panel"
echo "> Add the 'mount' scripts to the menu"
sleep 3;

# Try the default password to sudo up.
echo $GEM_PASSWORD | sudo -S true > /dev/null 2>&1

# Configure wireshark
echo -e "\e[1;33mConfigure wireshark...\e[0m"
echo $GEM_PASSWORD | sudo usermod -a -G wireshark $USER
echo $GEM_PASSWORD | sudo chgrp wireshark /usr/bin/dumpcap
echo $GEM_PASSWORD | sudo chmod 750 /usr/bin/dumpcap
echo $GEM_PASSWORD | sudo setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap

# Make the Terminal colourful
echo -e "\e[1;33mMake the Terminal colourful...\e[0m"
echo $GEM_PASSWORD | sudo sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/' ~/.bashrc
echo $GEM_PASSWORD | sudo sed -i 's/#export GCC_COLORS/export GCC_COLORS/' ~/.bashrc
source ~/.bashrc

# Delete the gemini user
echo -e "\e[1;33mDelete the gemini user...\e[0m"
echo $GEM_PASSWORD | sudo userdel -r gemini

# Remove some directories
echo -e "\e[1;33mRemove some directories...\e[0m"
rm -R ~/Documents
rm -R ~/Music
rm -R ~/Pictures
rm -R ~/Public
rm -R ~/Templates
rm -R ~/Videos

# Add some directories
echo -e "\e[1;33mAdd some directories...\e[0m"
mkdir ~/DEV
mkdir ~/DEV/RasPi
mkdir ~/APPS
mkdir ~/APPS/Arduino
mkdir ~/APPS/Arduino/sketchbook
mkdir ~/MOUNTS
mkdir ~/MOUNTS/HAL9000
mkdir ~/MOUNTS/monkeycam
mkdir ~/MOUNTS/piboard
mkdir ~/MOUNTS/robotcam
mkdir ~/MOUNTS/serverpi

# Add and configure the .ssh directory
echo -e "\e[1;33mAdd and configure the .ssh directory...\e[0m"
mkdir ~/.ssh
chmod 700 ~/.ssh

# Populate the .ssh directory
echo -e "\e[1;33mPopulate the .ssh directory...\e[0m"
touch ~/.ssh/authorized_keys
cp /media/$GEM_USERNAME/ED7A-1D21/temp/ssh/* ~/.ssh
chmod 400 ~/.ssh/*
chown $USER:$USER ~/.ssh/authorized_keys
chown $USER:$USER ~/.ssh
echo $GEM_PASSWORD | sudo systemctl restart ssh

# Add some scripts
echo -e "\e[1;33mAdd some scripts...\e[0m"
mkdir ~/.scripts
cp /media/$GEM_USERNAME/ED7A-1D21/temp/scripts/* ~/.scripts
echo $GEM_PASSWORD | sudo chmod u+x ~/.scripts/*

# Install Arduino from backup and configure
echo -e "\e[1;33mInstall Arduino from backup and configure...\e[0m"
tar -xf /media/$GEM_USERNAME/ED7A-1D21/temp/Arduino_IDE/arduino-1.8.19-linuxaarch64.tar.xz -C ~/APPS/Arduino
echo $GEM_PASSWORD | sudo sh ~/APPS/Arduino/arduino-1.8.19/install.sh
echo $GEM_PASSWORD | sudo sed -i 's+sketchbook.path=/home/$GEM_USERNAME/Arduino+sketchbook.path=/home/$GEM_USERNAME/APPS/Arduino/sketchbook+' /home/$GEM_USERNAME/.arduino15/preferences.txt
echo $GEM_PASSWORD | sudo usermod -a -G dialout $GEM_USERNAME

# Install VNC from backup
echo -e "\e[1;33mInstall VNC from backup...\e[0m"
echo $GEM_PASSWORD | sudo dpkg -i /media/$GEM_USERNAME/ED7A-1D21/temp/VNC_Viewer/VNC-Viewer-6.22.515-Linux-ARM64.deb

# Configure Conky & Compton
echo -e "\e[1;33mConfigure Conky...\e[0m"
cp /media/$GEM_USERNAME/ED7A-1D21/temp/Conky/.conkyrc ~/
touch ~/.config/autostart/conky.desktop
echo -e "[Desktop Entry]\nExec=/usr/bin/conky\nName=Conky\nType=Application\nVersion=1.0" | sudo tee ~/.config/autostart/conky.desktop
echo -e "[Desktop Entry]\nExec=/usr/bin/compton\nName=Compton\nType=Application\nVersion=1.0" | sudo tee ~/.config/autostart/compton.desktop

# Autohide the bottom panel
echo $GEM_PASSWORD | sudo sed -i 's+hidable=false+hidable=true+' ~/.config/lxqt/panel.conf
killall lxqt-panel && lxqt-panel &

# Add the 'mount' scripts to the menu
mkdir ~/.local/share/applications
touch ~/.local/share/applications/mount.desktop
echo -e "[Desktop Entry]\nVersion=1.0\nType=Application\nName=Mount-Local\nComment=Connect to other computer via sshfs (Local)\nIcon=knetattach\nExec=/home/simon/.scripts/mount_local.sh\nNoDisplay=false\nCategories=GTK;System;\nStartupNotify=false\nTerminal=false" | sudo tee ~/.local/share/applications/mount_local.desktop
echo -e "[Desktop Entry]\nVersion=1.0\nType=Application\nName=Mount-Remote\nComment=Connect to other computer via sshfs (Remote)\nIcon=knetattach\nExec=/home/simon/.scripts/mount_remote.sh\nNoDisplay=false\nCategories=GTK;System;\nStartupNotify=false\nTerminal=false" | sudo tee ~/.local/share/applications/mount_remote.desktop
echo -e "[Desktop Entry]\nVersion=1.0\nType=Application\nName=Unmount\nComment=Unmount all sshhs mountdts\nIcon=knetattach\nExec=/home/simon/.scripts/unmount.sh\nNoDisplay=false\nCategories=GTK;System;\nStartupNotify=false\nTerminal=false" | sudo tee ~/.local/share/applications/unmount.desktop
echo $GEM_PASSWORD | sudo chmod u+x ~/.local/share/applications/*.desktop

echo ""
echo -e "\e[1;36mDONE...\e[0m"
sleep 3;

clear
echo -e "\e[1;36m> This will check the configurations and apps have been installed correctly\e[0m"
echo "> Check that wireshark has been configured"
echo "> Check the user gemini has been completely removed"
echo "> Check the .ssh directory is populated"
echo "> Check the .scripts directory is populated"
echo "> Check that Arduino has been installed"
echo "> Check that Arduino has been configured"
echo "> Check that VNC has been installed"
echo "> Check that Conky has been installed"
echo "> Check that Conky has been configured"
echo "> Check the 'mount' scripts have been added to the menu"
sleep 3;

# Try the default password to sudo up.
echo $GEM_PASSWORD | sudo -S true > /dev/null 2>&1

# Check that wireshark has been configured
if [[ "$(echo $GEM_PASSWORD | sudo getcap /usr/bin/dumpcap)" == "/usr/bin/dumpcap = cap_net_admin,cap_net_raw+eip" ]]; then
    echo -e "Has wireshark been configured: \e[32mYes\e[0m"
else
    echo -e "Has wireshark been configured:: \e[31mNo\e[0m"
fi

# Check the user gemini has been completely removed
if [[ "$(cat /etc/group | grep gemini)" == "" ]]; then
    echo -e "Has the user gemini has been completely removed: \e[32mYes\e[0m"
else
    echo -e "Has the user gemini has been completely removed: \e[31mNo\e[0m"
fi

# Check the .ssh directory is populated
if [ -z "$(ls -A ~/.ssh)" ]; then
    echo -e "Is the .ssh directory populated: \e[31mNo\e[0m"
else
    echo -e "Is the .ssh directory populated: \e[32mYes\e[0m"
fi

# Check the .scripts directory is populated
if [ -z "$(ls -A ~/.scripts)" ]; then
    echo -e "Is the .scripts directory populated: \e[31mNo\e[0m"
else
    echo -e "Is the .scripts directory populated: \e[32mYes\e[0m"
fi

# Check that Arduino has been installed
FILE=~/APPS/Arduino/arduino-1.8.19/arduino
if test -f "$FILE"; then
    echo -e "Has Arduino has been installed: \e[32mYes\e[0m"
else
    echo -e "Has Arduino has been installed: \e[31mNo\e[0m"
fi

# Check that Arduino has been configured
grep -q '/APPS/Arduino/sketchbook' ~/.arduino15/preferences.txt
if [ $? -eq 0 ]; then 
	echo -e "Has Arduino been configured: \e[32mYes\e[0m"
else
	echo -e "Has Arduino been configured: \e[31mNo, needs to be opened once for preferences to be set\e[0m"
fi

# Check that VNC has been installed
if [[ "$(dpkg -s realvnc-vnc-viewer | grep Status)" == "Status: install ok installed" ]]; then
    echo -e "Has VNC has been installed: \e[32mYes\e[0m"
else
    echo -e "Has VNC has been installed: \e[31mNo\e[0m"
fi

# Check that Conky has been installed
FILE=~/.conkyrc
if test -f "$FILE"; then
    echo -e "Has Conky has been installed: \e[32mYes\e[0m"
else
    echo -e "Has Conky has been installed: \e[31mNo\e[0m"
fi

# Check that Conky has been configured
FILE=~/.config/autostart/conky.desktop
if test -f "$FILE"; then
    echo -e "Has Conky has been configured: \e[32mYes\e[0m"
else
    echo -e "Has Conky has been configured: \e[31mNo\e[0m"
fi

# Check the 'mount' scripts have been added to the menu
FILE=~/.local/share/applications/mount_local.desktop
if test -f "$FILE"; then
    echo -e "Have the 'mount' scripts have been added to the menu: \e[32mYes\e[0m"
else
    echo -e "Have the 'mount' scripts have been added to the menu: \e[31mNo\e[0m"
fi

echo ""
echo -e "\e[1;36mDONE...\e[0m"
echo ""
echo -e "\e[31mNeed to reboot to update the menu options\e[0m"
echo ""
