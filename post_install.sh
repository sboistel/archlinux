#!/bin/bash
#
#-- Script by Conejos Matthias - November 2017
#
#-- Arch Linux Post installation

## COLORING ##

red="\033[0;31m"
neut="\033[0m"
blue="\033[0;34m"
green_bold="\033[0;42m"

#-- Clear terminal

clear


#-- Welcome to Conejos.M Post-Install

echo -e """${green_bold}
* Welcome to Arch Linux post installation by Conejos.M *
${neut}
"""

sleep 1.5


#Change fstab relatime to noatime

sed -i "s/relatime/noatime/g" /etc/fstab


#Set Time Zone

echo -e """${red}

#==================================#
Set the time zone :

${neut} => ln -sf /usr/share/zoneinfo/Region/City /etc/localtime"""

ln -sf /usr/share/zoneinfo/UTC /etc/localtime

sleep 0.2

#Display current date 

date && echo -e """Ok, cool ;)"""

sleep 2


#Generate hwclock

echo -e """${red}

#==================================#
Running hwclock generator :

${neut} => hwclock --systohc --utc """

hwclock --systohc --utc


#Set Language & Keyboard.

echo -e """${red}

#==================================#
Set Language and keyboard :

${neut} => en_GB.UTF_8 UTF-8"""

sed -i -e """s/\#en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/g""" /etc/locale.gen


#Generate the LANG related configurations

echo -e """${red}

#==================================#
Generate the LANG related configurations :

${neut} =>  locale-gen"""

locale-gen


#Adding the LANG

echo -e """LANG=en_GB.UTF-8""" > /etc/locale.conf


#Set AZERTY keyboard

echo -e """KEYMAP=fr""" > /etc/vconsole.conf


#Set Hostname

echo -e """${red}

#==================================#
${neut}"""

read -rp $'\033[31mEnter the hostname of your new Arch system > \033[0m\n' hostname

echo -e """$hostname""" > /etc/hostname


#Set root passwd

echo -e """${red}

#==================================#
Please enter your new root password :

${neut}"""

passwd


#Set user account & password

echo -e """${red}

#==================================#
${neut}"""

read -rp $'\033[31mEnter LOWER the name of your new user account > \033[0m\n' account

useradd -m -G wheel -s /bin/bash $account

echo -e """${red}

#==================================#
Set $account password :

${neut}"""

passwd $account


#Edit sudoers file

sed -i "s/# %wheel ALL=(ALL) ALL/ %wheel ALL=(ALL) ALL/g" /etc/sudoers
echo 'Defaults env_keep += "http_proxy https_proxy ftp_proxy rsync_proxy no_proxy"' >> /etc/sudoers


#Set coloring into pacman | install vim & Set line number on

sed -ri 's/#Color/Color/g' /etc/pacman.conf

pacman -Syu

yes | pacman -S vim

echo -e """set nu""" >> /etc/vimrc 


#Set HOOKS Line

sed -ri 's/^HOOKS.*/HOOKS=(base udev block keyboard keymap encrypt lvm2 filesystems fsck)/' /etc/mkinitcpio.conf


#Generate your initrd iamge

echo -e """${red}

#==================================#
Generating your initrd image :
${neut} =>  mkinitcpio -p linux"""

read -rp $'\033[31mHit "Enter" to continue\033[0m\n'

mkinitcpio -p linux


#GRUB

echo -e """${red}

#==================================#
Grub downloading :

${neut}"""


#GRUB MBR/BIOS

yes | pacman -S grub efibootmgr 

echo -e """${red}
Grub installation
#==================================#
${neut}"""

echo "Remember ↓"

echo "-----------------------------------------------------------------------"
lsblk
echo "-----------------------------------------------------------------------"

read -rp $'\033[31mEnter the name of your disk as "/dev/sdx" > \033[0m\n' devsdx

grub-install --target=i386-pc --boot-directory /boot $devsdx


#GRUB EFI

grub-install --target=x86_64-efi --efi-directory /boot --boot-directory /boot --removable


#Configuration Grub

echo -e """${red}

#==================================#
Grub configuration, enter the name of the encrypted luks partition as '/dev/sdxx' :

    → Example: GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=54bf-........46446:ArchLUKS\"

Often /dev/sdx3

${neut}"""

read devsdxluks

sed -ri 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT=""/g' /etc/default/grub

sed -ri 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cryptdevice=:"/g' /etc/default/grub

blkid | grep -i $devsdxluks >> /etc/default/grub

vim /etc/default/grub


#Generate your final Grub Configuration

echo -e """${red}

#==================================#
Generating your final grub configuration :

${neut}"""

grub-mkconfig -o /boot/grub/grub.cfg


#Post installation

echo -e """${red}

#==================================#
    → Big pacman arrives, will take 42 cup of coffee bro :

${neut}"""

sleep 2

#Start dhcp deamon for internet connectivity
#systemctl start dhcpd

pacman -S bash-completion networkmanager network-manager-applet pulseaudio pulseaudio-alsa libpulse alsa-lib acpi xf86-video-vesa xf86-video-ati xf86-video-nouveau xf86-input-libinput polkit polkit-gnome gvfs gvfs-mtp gvfs-smb ntfs-3g gtk-engine-murrine file-roller eog evince xdg-user-dirs gnome-keyring ufw blueberry bluez bluez-cups bluez-firmware bluez-libs bluez-tools bluez-utils cups avahi gnome-bluetooth pulseaudio-bluetooth sbc system-config-printer foomatic-db foomatic-db-engine foomatic-db-gutenprint-ppds foomatic-db-nonfree foomatic-db-nonfree-ppds cups-filters gutenprint unrar net-tools gedit pavucontrol sshpass rofi nmap glances arc-gtk-theme arc-icon-theme


#Enabling Network Manager & UFW & CUPS & AVAHI

systemctl enable NetworkManager.service

systemctl enable ufw.service

systemctl enable cups-browsed.service

systemctl enable org.cups.cupsd

systemctl enable avahi-daemon.{service,socket}

systemctl enable avahi-dnsconfd.service


#Keep coulinje

echo -e """${red}

#==================================#
Installing thermald and sensors :

${neut}"""

pacman -S thermald lm_sensors

systemctl enable thermald 

#[[ ( $(lspci | grep -Eo "VGA.*" | grep -Eoi "Intel|Nvidia|Amd|Radeon") ) ]] && { sensors-detect && systemctl enable thermald ; } || echo -e """\n${red}Error: you are in a Virtual machine${neut}\n"
#sleep 2


#Installing Desktop Manager
#
#Installing lightdm & xorg

pacman -S xorg lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings

echo "greeter-setup-script=/usr/bin/setxkbmap fr" >> /etc/lightdm/lightdm.conf

systemctl enable lightdm.service


#Install desktop environnement

echo -e """${red}

#==================================#
${neut}"""

PS3=$'\033[0;31mSelect the Desktop environnement you want to install > \033[0m\n'
options=("Xfce4" "cinnamon" "i3" "Bspwm" "Quit")

select choice in "${options[@]}"; do

	case "$choice" in

		"Xfce4")
			DE="xfce4" && break
			;;
			
		"Cinnamon")
			DE="cinnamon" && break
			;;		
		"i3")
			DE="i3" && break
			;;

		"Bspwm")
			DE="bspwm sxhkd" && break
			;;

		"Quit")
			echo -e """\n${red}You did not select any DE${neut}\n""" && break
			;;

		*)
			echo -e """\n${red}WRONG CHOICE/OPTION${neut}\n"""
			;;
	esac
done

[[ -n "${DE}" ]] && pacman -S "${DE}"

[[ "${DE}" == "xfce4" ]] && pacman -S thunar-archive-plugin thunar-volman xfce4-notifyd xfce4-pulseaudio-plugin xfce4-screenshooter xfce4-sensors-plugin startup-notification


#Script utils

wget -O /usr/local/bin/updt "https://gitlab.com/Matthias.C/arch/raw/master/updt" 

chmod 777 /usr/local/bin/updt

#Trizen

echo "git clone https://aur.archlinux.org/trizen.git" >> /home/$account/aur

echo "cd trizen" >> /home/$account/aur

echo "makepkg -si" >> /home/$account/aur

echo "trizen -S neofetch --noedit" >> /home/$account/aur

echo "echo 'Check U'r system ↓'" >> /home/$account/aur

echo "neofetch" >> /home/$account/aur

echo "sleep 1 && rm -rf ../trizen.git" >> /home/$account/aur

echo -e """${red}

#==================================#
For install Trizen $account :

You need to run 'sh /home/$account/aur' as $account

${neut}"""


#Have Fun


echo -e """${red}

#==================================#
U can now have playing on U'r new ArchLinux System, congrate.

    → Enter this following command to update your system : ${green_bold}updt${neut}

${blue} And don't Forget, Keeping It Simple, Stupid!${neut}


      ▝▄      
      ▚▚      
     ▌▛▞▙      
    ▐▐▝▐▝▙     
   ▐▞▌  ▀▞▘    
  ▐▝▝   ▝▝▘▌   
 ▝                                      

"""

#END
