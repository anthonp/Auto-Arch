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
# Edited by @anthonp | 3-post-setup.sh
#----------------------------------------------------------------------------
echo -e "\nFINAL SETUP AND CONFIGURATION"

# ------------------------------------------------------------------------

echo -e "\nEnabling Login Display Manager"

sudo systemctl enable sddm.service

echo -e "\nSetup SDDM Theme"

sudo cat <<EOF > /etc/sddm.conf
[Theme]
Current=Nordic
EOF

# ------------------------------------------------------------------------

# This section provided by gitHub user @71Zombie/BetterArch

# Uncomplicated Firewall
sudo ufw limit 22/tcp
sudo ufw default deny incoming
sudo ufw default allow outgoing

# --- Harden /etc/sysctl.conf
sudo sysctl kernel.modules_disabled=1
sudo sysctl -a
sudo sysctl -A
sudo sysctl mib
sudo sysctl net.ipv4.conf.all.rp_filter
sudo sysctl -a --pattern 'net.ipv4.conf.(eth|wlan)0.arp'

# --- PREVENT IP SPOOFS
cat <<EOF > /etc/host.conf
order bind,hosts
multi on
EOF

# --- Enable fail2ban
sudo cp fail2ban.local /etc/fail2ban/

# ------------------------------------------------------------------------

echo -e "\nEnabling essential services"

systemctl enable cups.service
sudo ntpd -qg
sudo systemctl enable ntpd.service
sudo systemctl disable dhcpcd.service
sudo systemctl stop dhcpcd.service
sudo systemctl enable NetworkManager.service
# sudo systemctl enable bluetooth
sudo systemctl enable ufw
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
echo "
###############################################################################
# Cleaning
###############################################################################
"
# Remove no password sudo rights
sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Replace in the same state
cd $pwd
echo "
###############################################################################
# Done - Please Eject Install Media and Reboot
###############################################################################
"
