##############################################################################################
#								           Multilib
##############################################################################################

sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
sudo pacman -Sl multilib --noconfirm

##############################################################################################
#						  Instalando Desktop Enviroment / Driver NVIDIA
##############################################################################################

dialog --title "Driver NVIDIA" --yes-label "Sim" --no-label "Não" --yesno "Voce possui placa de video NVIDIA? :" 0 0

if [ $? == 0 ]
then
    if [ INTEL_PRO == 1 ]
    then
        sudo pacman -Sy nvidia nvidia-utils nvidia-settings lib32-nvidia-utils optimus-manager optimus-manager-qt bbswitch --noconfirm
        sudo echo "[optimus]" > /etc/optimus-manager/optimus-manager.conf
        sudo echo "auto_logout=yes" >> /etc/optimus-manager/optimus-manager.conf
        sudo echo "pci_power_control=no" >> /etc/optimus-manager/optimus-manager.conf
        sudo echo "pci_remove=no" >> /etc/optimus-manager/optimus-manager.conf
        sudo echo "pci_reset=no" >> /etc/optimus-manager/optimus-manager.conf
        sudo echo "startup_auto_battery_mode=hybrid" >> /etc/optimus-manager/optimus-manager.conf
        sudo echo "startup_auto_extpower_mode=hybrid" >> /etc/optimus-manager/optimus-manager.conf
        sudo echo "startup_mode=hybrid" >> /etc/optimus-manager/optimus-manager.conf
        sudo echo "switching=bbswitch" >> /etc/optimus-manager/optimus-manager.conf
    else
        sudo pacman -Sy nvidia nvidia-utils nvidia-settings lib32-nvidia-utils --noconfirm
    fi
fi

sudo pacman -Sy --needed xorg xorg-apps gnome gdm gnome-terminal gnome-system-monitor gedit evince \
pulseaudio pulseaudio-alsa pulseaudio-bluetooth pulseaudio-equalizer pulseaudio-jack pulseaudio-lirc pulseaudio-zeroconf \
neofetch bluez bluez-utils blueman noto-fonts ttf-liberation ttf-droid ttf-ubuntu-font-family ttf-roboto ttf-liberation \
chromium git base-devel xdg-user-dirs lsb-release go jdk11-openjdk bash --noconfirm

sudo systemctl enable gdm.service
sudo systemctl enable bluetooth.service
sudo xdg-user-dirs-update
sudo rm -rf /etc/profile/alpha3.sh
