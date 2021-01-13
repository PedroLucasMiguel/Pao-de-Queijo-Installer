#! bin/bash

##############################################################################################
#						Instalando dependencias/Network Manager
##############################################################################################

pacman -Sy dialog pacman-contrib networkmanager --noconfirm
systemctl enable NetworkManager
NetworkManager


##############################################################################################
#											Intro
##############################################################################################

dialog --title "Bem-vindo ao Pao de Queijo Installer" --msgbox \
"A partir de agora vamos guiar você durante toda a instalação do sistema.\nAperte OK para continuar" 0 0


##############################################################################################
#									Configurando teclado
##############################################################################################

loadkeys br-abnt


##############################################################################################
#									Testando conexão
##############################################################################################

ping google.com -c 1
RESULT=$?
if [ $RESULT == 0 ]
then
    dialog --title "Online!" --msgbox "Sua conexão está funcionando normalmente!" 0 0
else
    dialog --title "Offline..." --yes-label "Sim" --no-label "Não" --yesno \
	"Ops, parece que você não esta conectado a internet\n\
	é de extrema importancia a conexão com a rede, pois sera atraves dela que faremos a instalação\n\
	Se a sua máquina possuir suporte para WIFI selecione Sim, caso contrário, selecione Não." 0 0
	clear
	if [ $? == 0 ]
	then
		RESULT=1
		while [ $RESULT != 0 ]
		do
			dialog --title "Configuração do WIFI" --msgbox "Na próxima tela, selecione a sua rede e realize a conexão normalmente" 0 0
			nmtui
			ping google.com -c 1
			RESULT=$?
			if [ $RESULT == 0 ]
			then
				dialog --title "Online!" --msgbox "Sua conexão está funcionando normalmente!" 0 0
			else
				dialog --title "Offline..." --yes-label "Sim" --no-label "Não" --yesno \
				"Sua conexão parece ainda não estar funcionando, deseja tentar novamente?" 00
				OP = $?
				if [ $OP != 0 ]
				then
					RESULT = 0
				fi
			fi
		done

		if [ $OP != 0 ]
		then
			exit 1
		fi
	else
		exit 1
	fi
fi


##############################################################################################
#									Detectando sistema de boot
##############################################################################################
:"
ls /sys/firmware/efi/efivars
RESULT=$?
clear
if [ $RESULT == 0 ]
then
    EFI=1
    dialog --title "Sistema de boot - EFI" --msgbox \
	"Detectamos que o sistema de boot é EFI!" 0 0
else
    EFI=0
    dialog --title "Sistema de boot - BIOS" --msgbox \
	"Detectamos que o sistema de boot é BIOS!" 0 0
#fi
"

##############################################################################################
#								Demonio...Digo Particionamento
##############################################################################################

dialog --title "Configuração da unidade de instalação" --msgbox \
"IMPORTANTE!!!!\nPao-de-Queijo_OS AINDA NÃO SUPORTA DUAL BOOT!" 0 0

dialog --title "Configuração da unidade de instalação" --msgbox \
"Na próxima tela, escolha em qual unidade deseja realizar a instalação dos sistema" 0 0

ITEMS=$(lsblk -d -p -n -l -o NAME,MODEL -e 7,11)
OPTIONS=()
for ITEM in ${ITEMS}
do
	OPTIONS+=("${ITEM}")
done
DISK=$(dialog --title "Escolha o disco para realizar a instalacao" --menu "Discos" 0 0 0 "${OPTIONS[@]}" --stdout)

dialog --title "AVISO!" --msgbox "Na proxima tela você ira escolher o método de instalação.\nCaso escolha\
 o método automático, SAIBA QUE TODOS OS ARQUIVOS PRESENTES NO DISCO SELECIONADO SERÃO APAGADOS, então lembre\
 de fazer um backup antes de escolher esta opção." 0 0

OP=$(dialog --title "Configuração da unidade de instalação" --menu "Escolha o tipo de instalção" 0 0 0 \
automatica "Faremos tudo por voce" manual "Você particiona como quiser" --stdout)

if [ $OP == "automatica" ]
then
	sgdisk -Z ${DISK} #Limpa o disco inteiro
	dialog --title "Particionamento" --msgbox \
	"Após apertar OK fique tranquilo, a janela ira sumir e varios comandos aparecerão na tela.\nMas tudo isso faz parte do nosso processo de instação automatica :p" 0 0
	clear
	echo "Definindo partition table como GPT"
	parted ${DISK} mklabel gpt
	echo "Criando particao de BOOT"
	sgdisk ${DISK} -n=1:0:+550M
	echo "Criando SWAP"
	sgdisk ${DISK} -n=2:0:+2048M
	echo "Criando root"
	sgdisk ${DISK} -n=3:0:0
	echo "Formatando"
	mkfs.fat -F32 ${DISK}1
	mkswap ${DISK}2
	mkfs.ext4 -F ${DISK}3
	echo "Montando..."
	echo "Root"
	mount ${DISK}3 /mnt
	echo "Swap"
	swapon ${DISK}2
	echo "Baixando arquivos do arch"
	pacstrap /mnt base linux linux-firmware
	echo "Gerando FSTab"
	genfstab -U /mnt >> /mnt/etc/fstab
	echo "Boot"
	mkdir /mnt/boot/EFI
	mount ${DISK}1 /mnt/boot/EFI
	curl -L https://raw.githubusercontent.com/PedroLucasMiguel/Pao-de-Queijo-Installer/main/alpha2.sh > alpha2.sh
	mv alpha2.sh /mnt
	chmod +x /mnt/alpha2.sh
	arch-chroot /mnt ./alpha2.sh
	umount -R /mnt
	reboot

else
	echo "Manual"
fi
