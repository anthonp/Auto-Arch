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
# Edited by @anthonp | 2-user.sh
#----------------------------------------------------------------------------
echo -e "\nINSTALLING AUR SOFTWARE\n"
# You can solve users running this script as root with this and then doing the same for the next for statement. However I will leave this up to you.

echo "CLONING: YAY"
cd ~
git clone "https://aur.archlinux.org/yay.git"
cd ${HOME}/yay
makepkg -si --noconfirm
cd ~
touch "$HOME/.cache/zshhistory"
git clone "https://github.com/ChrisTitusTech/zsh"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/powerlevel10k
ln -s "$HOME/zsh/.zshrc" $HOME/.zshrc

PKGS=(
'autojump'
'awesome-terminal-fonts'
'brave-bin' # Brave Browser
'element-desktop-git' # Element Messenger
'firefox' # Firefox
'dxvk-bin' # DXVK DirectX to Vulcan
'github-desktop-bin' # Github Desktop sync
'lightly-git'
'nerd-fonts-fira-code'
'nordic-darker-standard-buttons-theme'
'nordic-darker-theme'
'nordic-kde-git'
'nordic-theme'
'noto-fonts-emoji'
'papirus-icon-theme'
'pidgin' # XMPP/IRC messager
'plasma-pa'
'ocs-url' # install packages from websites
'ungoogled-chromium' # As it sounds
'sddm-nordic-theme-git'
'snapper-gui-git'
'ttf-droid'
'ttf-hack'
'ttf-meslo' # Nerdfont package
'ttf-roboto'
'snap-pac'
'youtubedl-gui-git'
'youtube-dl'
)

for PKG in "${PKGS[@]}"; do
    yay -S --noconfirm $PKG
done

# Fish
mkdir $HOME/.config/fish
cp /root/Auto-Arch/dotfiles/fish/config.fish $HOME/.config/fish/

export PATH=$PATH:~/.local/bin
cp -r $HOME/Auto-Arch/dotfiles/* $HOME/.config/
pip install konsave
konsave -i $HOME/Auto-Arch/kde.knsv
sleep 1
konsave -a kde

# Portmaster by Safing.io
echo -e "\nInstalling Portmaster, by Safing\n"
mkdir -p /var/lib/portmaster
wget -O /tmp/portmaster-start https://updates.safing.io/latest/linux_amd64/start/portmaster-start
sudo mv /tmp/portmaster-start /var/lib/portmaster/portmaster-start
sudo chmod a+x /var/lib/portmaster/portmaster-start
sudo /var/lib/portmaster/portmaster-start --data /var/lib/portmaster update
sudo /var/lib/portmaster/portmaster-start core
git clone https://github.com/safing/portmaster-packaging/ /tmp/portmaster-packaging
sudo cp /tmp/portmaster-packaging/blob/master/linux/debian/portmaster.service /etc/systemd/system/
sudo systemctl enable --now portmaster

echo -e "\nDone!\n"
exit
