#!/usr/bin/env bash
#----------------------------------------------------------------------------
#
#      **               **                      **                    **     
#     ****             /**                     ****                  /**     
#    **//**   **   ** ******  ******          **//**   ******  ***** /**     
#   **  //** /**  /**///**/  **////** *****  **  //** //**//* **///**/****** 
#  **********/**  /**  /**  /**   /**/////  ********** /** / /**  // /**///**
# /**//////**/**  /**  /**  /**   /**      /**//////** /**   /**   **/**  /**
# /**     /**//******  //** //******       /**     /**/***   //***** /**  /**
# //      //  //////    //   //////        //      // ///     /////  //   // 
#
#----------------------------------------------------------------------------
# Edited by @anthonp | 1-setup.sh
#----------------------------------------------------------------------------
echo "--------------------------------------"
echo "--          Network Setup           --"
echo "--------------------------------------"
pacman -S networkmanager dhclient --noconfirm --needed
systemctl enable --now NetworkManager
echo "-------------------------------------------------"
echo "Setting up mirrors for optimal download          "
echo "-------------------------------------------------"
pacman -S --noconfirm pacman-contrib curl
pacman -S --noconfirm reflector rsync
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

nc=$(grep -c ^processor /proc/cpuinfo)
echo "You have " $nc" cores."
echo "-------------------------------------------------"
echo "Changing the makeflags for "$nc" cores."
TOTALMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  $TOTALMEM -gt 8000000 ]]; then
sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$nc"/g' /etc/makepkg.conf
echo "Changing the compression settings for "$nc" cores."
sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g' /etc/makepkg.conf
fi
echo "-------------------------------------------------"
echo "       Setup Language to US and set locale       "
echo "-------------------------------------------------"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
timedatectl --no-ask-password set-timezone America/Chicago
timedatectl --no-ask-password set-ntp 1
localectl --no-ask-password set-locale LANG="en_US.UTF-8" LC_TIME="en_US.UTF-8"

# Set keymaps
localectl --no-ask-password set-keymap us

# Add sudo no password rights
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

#Add parallel downloading
sed -i 's/^#Para/Para/' /etc/pacman.conf

#Enable multilib
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm

echo -e "\nInstalling Base System\n"

PKGS=(
'mesa' # Essential Xorg First
'xorg'
'xorg-server'
'xorg-apps'
'xorg-drivers'
'xorg-xkill'
'xorg-xinit'
'xterm'
'plasma-desktop' # KDE Load second
'alsa-plugins' # audio plugins
'alsa-utils' # audio utils
'apparmor' # Security module
'appimagelauncher'
'ark' # compression
'audiocd-kio' 
'autoconf' # build
'automake' # build
'base'
'bash-completion'
'bettercap' # Swiss army knife for network attacks and monitoring
'bind'
'binutils'
'bison'
'bluedevil'
'bluez'
'bluez-libs'
'breeze'
'breeze-gtk'
'bridge-utils'
'btrfs-progs'
'celluloid' # video players
'code' # Visual Studio code
'cronie'
'cups'
'dialog'
'discover'
'dolphin'
'dosfstools'
'efibootmgr' # EFI boot
'egl-wayland'
'exfat-utils'
'fail2ban' # Bans IPs after too many failed authentication attempts
'flex'
'fuse2'
'fuse3'
'firejail' # Application Sandboxing
'fuseiso'
'gamemode'
'gcc'
'gimp' # Photo editing
'git'
'gparted' # partition management
'gptfdisk'
'grub'
'grub-customizer'
'gst-libav'
'gst-plugins-good'
'gst-plugins-ugly'
'haveged'
'htop'
'iptables-nft'
'jdk-openjdk' # Java 17
'kate'
'kvantum-qt5'
'kde-gtk-config'
'kitty'
'konsole'
'layer-shell-qt'
'libnewt'
'libtool'
'linux-firmware'
'linux-hardened' # Linux hardening
'linux-hardened-headers' # Linux hardening
'lsof'
'lzop'
'm4'
'make'
'metasploit' # Exploit
'milou'
'nano'
'neofetch'
'networkmanager'
'nmap' # Network scanning program
'ntfs-3g'
'ntp'
'okular'
'openbsd-netcat'
'openssh'
'os-prober'
'oxygen'
'p7zip'
'pacman-contrib'
'patch'
'picom'
'pkgconf'
'plasma-nm'
'powerline-fonts'
'print-manager'
'protonvpn'
'pulseaudio'
'pulseaudio-alsa'
'pulseaudio-bluetooth'
'python-pip'
'qemu'
'rsync'
'sddm'
'sddm-kcm'
'snapper'
'spectacle'
'sublime-text-4'
'sudo'
'swtpm'
'synergy'
'systemsettings'
'terminus-font'
'traceroute'
'ufw'
'unrar'
'unzip'
'usbutils'
'vim'
'virt-manager'
'virt-viewer'
'vlc' # Media Player
'wget'
'which'
'wine-gecko'
'wine-mono'
'winetricks'
'xdg-desktop-portal-kde'
'xdg-user-dirs'
'zeroconf-ioslave'
'zip'
'zsh'
'zsh-syntax-highlighting'
'zsh-autosuggestions'
)

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

#
# determine processor type and install microcode
# 
proc_type=$(lscpu | awk '/Vendor ID:/ {print $3}')
case "$proc_type" in
	GenuineIntel)
		print "Installing Intel microcode"
		pacman -S --noconfirm intel-ucode
		proc_ucode=intel-ucode.img
		;;
	AuthenticAMD)
		print "Installing AMD microcode"
		pacman -S --noconfirm amd-ucode
		proc_ucode=amd-ucode.img
		;;
esac	

# Graphics Drivers find and install
if lspci | grep -E "NVIDIA|GeForce"; then
    pacman -S nvidia --noconfirm --needed
	nvidia-xconfig
elif lspci | grep -E "Radeon"; then
    pacman -S xf86-video-amdgpu --noconfirm --needed
elif lspci | grep -E "Integrated Graphics Controller"; then
    pacman -S libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils --needed --noconfirm
fi

echo -e "\nDone!\n"
if ! source install.conf; then
	read -p "Please enter username:" username
echo "username=$username" >> ${HOME}/Auto-Arch/install.conf
fi
if [ $(whoami) = "root"  ];
then
    useradd -m -G wheel,libvirt -s /bin/bash $username 
	passwd $username
	cp -R /root/Auto-Arch /home/$username/
    chown -R $username: /home/$username/Auto-Arch
	read -p "Please name your machine:" nameofmachine
	echo $nameofmachine > /etc/hostname
else
	echo "You are already a user proceed with aur installs"
fi

