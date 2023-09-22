#! /bin/bash

base="dmenu rxvt-unicode i3-wm i3blocks i3lock i3status dunst rofi libnotify"
utility="acpi arandr bridge-utils inotify-tools inetutils xautolock logrotate net-tools smartmontools tlp xdotool lxappearance xfsprogs xprintidle xssstate git unrar unzip zip p7zip gzip"
audio="pavucontrol pulseaudio-alsa lib32-alsa-plugins alsa-tools alsa-utils lib32-libpulse"
applications="cmus htop unclutter feh deluge-gtk firefox leafpad mpv mupdf neofetch obsidian ranger rclone redshift tmux viewnior"
fonts="adobe-source-han-sans-jp-fonts adobe-source-han-sans-kr-fonts ttf-liberation ttf-font-awesome"
extraa="android-tools"
pacman -Sy
pacman -S --needed $base $utility $audio $applications $fonts $extra

# Needed for startx
cat << EOF > /home/kenneth/.xinitrc
userresources=$HOME/bin/src/.Xresources
if [ -f $userresources ]; then
    xrdb -merge $userresources
fi

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

# Add extra fonts folder
cat << EOF > /etc/fonts/local.conf
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
 <dir>/home/kenneth/bin/src/fonts</dir>
</fontconfig>
EOF

# Set ranger to show hidden files by default
cat << EOF > /home/kenneth/.config/ranger/rc.conf
set show_hidden true
EOF

