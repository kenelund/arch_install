#! /bin/bash

core_install="dmenu rxvt-unicode i3-wm i3blocks i3lock i3status dunst feh htop rofi unclutter"
core_dependencies="acpi alsa-tools alsa-utils android-tools arandr bridge-utils inotify-tools inetutils libnotify lib32-alsa-plugins lib32-libpulse logrotate net-tools pavucontrol pulseaudio-alsa smartmontools tlp xautolock xdotool xfsprogs xprintidle xssstate git"
applications="cmus deluge-gtk firefox leafpad mpv mupdf neofetch obsidian ranger rclone redshift tmux viewnior"
extra="adobe-source-han-sans-jp-fonts adobe-source-han-sans-kr-fonts ttf-liberation"
pacman -S --needed $core_install $core_dependencies $applications $extra

# arch user repoaitory
cd /root
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
rmdir yay

# yay -S google-chrome i3blocks-contrib

