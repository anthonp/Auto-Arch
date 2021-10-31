Auto-Arch#!/bin/bash

    bash 0-preinstall.sh
    arch-chroot /mnt /root/Auto-Arch/1-setup.sh
    source /mnt/root/Auto-Arch/install.conf
    arch-chroot /mnt /usr/bin/runuser -u $username -- /home/$username/Auto-Arch/2-user.sh
    arch-chroot /mnt /root/Auto-Arch/3-post-setup.sh
