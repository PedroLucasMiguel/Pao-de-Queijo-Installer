#! bin/bash

##############################################################################################
#								Instalando dependencias/utils
##############################################################################################

pacman -S dialog --noconfirm
pacman -S nano sed --noconfirm


##############################################################################################
#								Definindo timezone
##############################################################################################

echo "Definindo timzeone para são paulo"
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc


##############################################################################################
#								Gerando arquivos de linguagem
##############################################################################################

echo "Gerando arquivos de idioma"
sed -i 's/#pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=pt_BR.UTF-8" > /etc/locale.conf
echo "KEYMAP=br-abnt" >> /etc/locale.conf


##############################################################################################
#								Arquivos de Host
##############################################################################################

HNAME=$(dialog --title "Nome do PC" --inputbox "Digite um nome para o PC:" 0 0 --stdout)
clear
echo "Gerando arquivos de rede"
echo ${HNAME} > /etc/hostname
echo "127.0.0.1     localhost" >> /etc/hosts
echo "::1           localhost" >> /etc/hosts
echo "127.0.1.1     ${HNAME}.localdomain  ${HNAME}" >> /etc/hosts


##############################################################################################
#								           Multilib
##############################################################################################

sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sl multilib --noconfirm

##############################################################################################
#							        Seleção de Processador
##############################################################################################

OP=$(dialog --title "Microcode e Driver gráfico" --menu "Escolha a fabricante do seu processador:" 0 0 0 \
Intel "celeron, i3, i5, i7, i9, xeon, etc..." AMD "Atlom, FX, Zen, etc...." --stdout)
if [ $OP == "Intel" ]
then
    clear
    INTEL_PRO=1
    echo "Instalando drivers e microcode Intel"
    pacman -Sy intel-ucode xf86-video-intel mesa lib32-mesa --noconfirm
else
    clear
    echo "Instalando drivers e microcode AMD"
    pacman -Sy amd-ucode xf86-video-amdgpu xf86-video-ati mesa lib32-mesa --noconfirm
fi


##############################################################################################
#								 BootLoader/Network Manager
##############################################################################################

echo "Instalando bootloader!"
pacman -Sy grub efibootmgr dosfstools os-prober mtools --noconfirm


grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
grub-mkconfig -o /boot/grub/grub.cfg

pacman -Sy networkmanager --noconfirm
systemctl enable NetworkManager


##############################################################################################
#						  Instalando Desktop Enviroment / Driver NVIDIA
##############################################################################################

dialog --title "Driver NVIDIA" --yes-label "Sim" --no-label "Não" --yesno "Voce possui placa de video NVIDIA? :" 0 0

if [ $? == 0 ]
then
    if [ INTEL_PRO == 1 ]
    then
        pacman -Sy nvidia nvidia-utils nvidia-settings lib32-nvidia-utils optimus-manager optimus-manager-qt bbswitch --noconfirm
        echo "[optimus]" > /etc/optimus-manager/optimus-manager.conf
        echo "auto_logout=yes" >> /etc/optimus-manager/optimus-manager.conf
        echo "pci_power_control=no" >> /etc/optimus-manager/optimus-manager.conf
        echo "pci_remove=no" >> /etc/optimus-manager/optimus-manager.conf
        echo "pci_reset=no" >> /etc/optimus-manager/optimus-manager.conf
        echo "startup_auto_battery_mode=hybrid" >> /etc/optimus-manager/optimus-manager.conf
        echo "startup_auto_extpower_mode=hybrid" >> /etc/optimus-manager/optimus-manager.conf
        echo "startup_mode=hybrid" >> /etc/optimus-manager/optimus-manager.conf
        echo "switching=bbswitch" >> /etc/optimus-manager/optimus-manager.conf
    else
        pacman -Sy nvidia nvidia-utils nvidia-settings lib32-nvidia-utils --noconfirm
    fi
fi

pacman -Sy --needed xorg xorg-apps cinnamon gdm gnome-terminal gnome-system-monitor gedit evince \
pulseaudio pulseaudio-alsa pulseaudio-bluetooth pulseaudio-equalizer pulseaudio-jack pulseaudio-lirc pulseaudio-zeroconf \
neofetch bluez bluez-utils blueman noto-fonts ttf-liberation ttf-droid ttf-ubuntu-font-family ttf-roboto ttf-liberation \
chromium git base-devel xdg-user-dirs lsb-release go jdk11-openjdk --noconfirm

systemctl enable gdm.service
systemctl enable bluetooth.service

USERNAME=$(dialog --title "Nome de usuario" --inputbox "Digite o nome do seu usuario:" 0 0 --stdout)
PASSROOT=$(dialog --title "Senha de ADM/Usuario" --inputbox "Digite uma senha para seu usuario:" 0 0 --stdout)
clear
echo "root:${PASSROOT}" | chpasswd
useradd -m ${USERNAME}
echo "${USERNAME}:${PASSROOT}" | chpasswd
usermod -aG wheel,audio,video,optical,storage ${USERNAME}
pacamn -Sy sudo --noconfirm
echo "${USERNAME}  ALL=(ALL:ALL) ALL" >> /etc/sudoers 
clear

su ${USERNAME} -c "xdg-user-dirs-update"


##############################################################################################
#						  Estilizando o pão de queijo :p
##############################################################################################

#OSNAME="DISTRIB_DESCRIPTION=\"Pao De Queijo OS\""
#sed -i --expression "s@DISTRIB_DESCRIPTION=\"Arch Linux\"@$OSNAME@" /etc/lsb-release

