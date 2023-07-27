#! /bin/bash

base="dmenu rxvt-unicode i3-wm i3blocks i3lock i3status dunst feh htop rofi unclutter xautolock"
utility="acpi alsa-tools alsa-utils arandr bridge-utils inotify-tools inetutils libnotify lib32-alsa-plugins lib32-libpulse logrotate net-tools pavucontrol pulseaudio-alsa smartmontools tlp xdotool xfsprogs xprintidle xssstate git unrar unzip zip p7zip gzip"
applications="cmus deluge-gtk firefox leafpad mpv mupdf neofetch obsidian ranger rclone redshift tmux viewnior"
fonts="adobe-source-han-sans-jp-fonts adobe-source-han-sans-kr-fonts ttf-liberation"
extraa="android-tools"
pacman -Sy
pacman -S --needed $base $utility $applications $fonts $extra

# Needed for startx
cat << EOF > /home/kenneth/.xinitrc
for i in /home/kenneth/bin/*.sh
do
  . $i &
done

unclutter &
exec i3
EOF

# Set keyboard language for xorg
cat << EOF > /etc/X11/xorg.conf.d/00-keyboard.conf
Section "InputClass"
  Identifier "system-keyboard"
  MatchIsKeyboard "on"
  Option "XkbLayout" "no"
EndSection
EOF

# Load custom vim file
cat << EOF > /home/kenneth/.vimrc
source /home/kenneth/bin/src/.vimrc
EOF

# Load custom tmux file
cat << EOF > /home/kenneth/.tmux.conf
source /home/kenneth/bin/src/.tmux.conf
EOF

# Load custom resource file for urxvt-unicode
cat << EOF > /home/kenneth/.Xresources
source /home/kenneth/bin/src/.Xresources
EOF


# arch user repoaitory
#cd /root
#git clone https://aur.archlinux.org/yay.git
#cd yay
#makepkg -si
#rmdir yay

# yay -S google-chrome i3blocks-contrib




# Setup login management - no display manager
#mkdir /etc/systemd/system/getty@tty1.service.d

#cat << EOF > /etc/systemd/system/getty@tty1.service.d/autologin.conf
#[Service]
#ExecStart=
#ExecStart=-/bin/autologin.sh %I
#EOF

#cat << EOF > /bin/autologin.sh
##!/bin/sh
#if [ -f /tmp/autologin ]
#then
#  exec /sbin/agetty --autologin kenneth --noclear $1
#else
#  exec /sbin/agetty --noclear $1
#fi
#EOF
#chmod a+x /bin/autologin.sh
