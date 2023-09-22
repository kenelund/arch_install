# Setup login management - no display manager (to be done after system install and reboot out of chroot)
# password protection in my case is handled by i3locks

mkdir /etc/systemd/system/getty@tty1.service.d

cat << EOF > /etc/systemd/system/getty@tty1.service.d/autologin.conf
[Service]
ExecStart=
ExecStart=-/bin/autologin.sh %I
EOF

cat << EOF > /etc/systemd/system/onetimelogin.service
[Unit]
Description=Prepare one time login

[Service]
Type=oneshot
ExecStart=-/bin/touch /tmp/autologin
ExecStart=-/bin/chown kenneth:users /tmp/autologin

[Install]
WantedBy=basic.target
EOF

systemctl enable onetimelogin.service

cat << EOF > /bin/autologin.sh
#!/bin/sh
if [ -f /tmp/autologin ]
then
  exec /sbin/agetty --autologin kenneth --noclear $1 38400 linux
else
  exec /sbin/agetty --noclear $1 38400 linux
fi
EOF

chmod a+x /bin/autologin.sh

# Bash profile for automatic start x
cat << EOF > /home/kenneth/.bash_profile
[[ -f ~/.bashrc ]] && . ~/.bashrc;

if [ -f /tmp/autologin ]; then
  rm /tmp/autologin
  exec startx
fi
EOF



# arch user repoaitory
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
rmdir yay

yay -S google-chrome i3blocks-contrib dropbox nordic-theme zafiro-icon-theme
