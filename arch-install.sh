#!/bin/bash

HOSTNAME=arch
KEYMAP=it
#STATICIP=127.0.1.1
STATICIP=127.0.1.1
#LOCALDOMAIN=localdomain
LOCALDOMAIN=localdomain
ROOT_PASSWORD=password
USER=user
USER_PASSWORD=password


# Set local time
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
hwclock --systohc

# en_US and it_IT UTF-8 locales
sed -i '177s/.//' /etc/locale.gen
sed -i '297s/.//' /etc/locale.gen
locale-gen

# Set variables
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf

# Host configuration
echo $HOSTNAME > /etc/hostname
echo "127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4" > /etc/hosts
echo "127.0.0.1 localhost localhost.localdomain localhost6 localhost6.localdomain6" >> /etc/hosts
echo "$STATICIP $HOSTNAME $HOSTNAME.$LOCALDOMAIN" >> /etc/hosts

# Set root password
echo root:$ROOT_PASSWORD | chpasswd

# Install GRUB
grub-install --target=x86_64-efi --efi-directory=/boot --boot-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Start services and timers
systemctl enable NetworkManager
systemctl enable reflector.timer
systemctl enable fstrim.timer

# Symlink vim to vi
ln -sf /usr/bin/vim /usr/bin/edit
ln -sf /usr/bin/vim /usr/bin/ex
ln -sf /usr/bin/vim /usr/bin/vedit
ln -sf /usr/bin/vim /usr/bin/vi
ln -sf /usr/bin/vim /usr/bin/view
ln -sf /usr/share/man/man1/vim.1.gz /usr/share/man/man1/edit.1.gz
ln -sf /usr/share/man/man1/vim.1.gz /usr/share/man/man1/ex.1.gz
ln -sf /usr/share/man/man1/vim.1.gz /usr/share/man/man1/vedit.1.gz
ln -sf /usr/share/man/man1/vim.1.gz /usr/share/man/man1/vi.1.gz
ln -sf /usr/share/man/man1/vim.1.gz /usr/share/man/man1/view.1.gz

# Add user and respective groups
useradd -m -G wheel $USER
echo $USER:$USER_PASSWORD | chpasswd

# Sudo rules for wheel group
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel

# Install packages
su $USER
cat pkgs | grep -v ^# | tr ' ' '\n' | grep . | paru -Syy --needed --noconfirm -
exit

printf "\e[1;32mDone! Type exit, umount -a and reboot.\e[0m\n"

