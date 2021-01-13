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

pacman -Sy networkmanager sudo --noconfirm
systemctl enable NetworkManager

##############################################################################################
#								 Criando usuario
##############################################################################################
USERNAME=$(dialog --title "Nome de usuario" --inputbox "Digite o nome do seu usuario:" 0 0 --stdout)
PASSROOT=$(dialog --title "Senha de ADM/Usuario" --inputbox "Digite uma senha para seu usuario:" 0 0 --stdout)
clear
echo "%wheel      ALL=(ALL) ALL" >> /etc/sudoers
echo "root:${PASSROOT}" | chpasswd
useradd -mg wheel ${USERNAME}
echo "${USERNAME}:${PASSROOT}" | chpasswd
echo "${USERNAME}   ALL=(ALL) ALL" >> /etc/sudoers
clear
exit