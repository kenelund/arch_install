#! /bin/bash

# Appending pacman config to enable multilib repository
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

# Set date time
ln -sf /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
hwclock --systohc
systemctl enable systemd-timesyncd.service

# Set locale to en_US.UTF-8 UTF-8
sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# Set keyboard language
echo "KEYMAP=no" >> /etc/vconsole.conf

# Set hostname
echo "CZLN01" >> /etc/hostname

# Generate initramfs
mkinitcpio -P

# Set root password
echo "Set root password!"
passwd

# Install bootloader
bootctl --path=/boot install

cat << EOF > /boot/loader/loader.conf
default		arch
timeout		5
editor		0
EOF

cat << EOF > /boot/loader/entries/arch.conf
title		Arch Linux
linux		/vmlinuz-linux
initrd		/intel-ucode.img
initrd		/initramfs-linux.img
options		root=/dev/sda2 rw intel_pstate=disable intel_idle.max_cstate=1
EOF

# Update bootloader - adds pacman hook to auto-update bootloader when systemd is upgraded
[[ ! -d "/etc/pacman.d/hooks" ]] && mkdir /etc/pacman.d/hooks

cat << EOF > /etc/pacman.d/hooks/systemd-boot.hook
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd
[Action]
Description = Updating systemd-boot...
When = PostTransaction
Exec = /usr/bin/bootctl update
EOF


# pacman_hook pacman cache maintenance - automatic cleanup of old update packages
# assumes 'pacman-contrib' package is installed
[[ ! -d "/etc/pacman.d/hooks" ]] && mkdir /etc/pacman.d/hooks

cat << EOF > /etc/pacman.d/hooks/paccache.hook
[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Package
Target = *
[Action]
Description = Cleaning pacman cache...
When = PostTransaction
Exec = /usr/bin/paccache --remove
EOF


# Create new user
useradd -m -G wheel,power,input,storage,uucp,network -s /bin/bash kenneth
sed --in-place 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers.d/10-wheel-group
echo "Set password for new user kenneth"
passwd kenneth

# Environmet configuration
echo -e 'EDITOR=vim' > /etc/environment
sed --in-place 's/#Color/Color/' /etc/pacman.conf

# Network Configuration
cat << EOF > /etc/systemd/network/10-lan.network
# 10-lan.network
[Match]
Name=enp0s25
[Network]
DHCP=ipv4
[Match]
RouteMetric=10
EOF

cat << EOF > /etc/systemd/network/20-wifi.network
# 20-wifi.network
[Match]
Name=wlo1
[Network]
DHCP=ipv4
[Match]
RouteMetric=20
EOF

cat << EOF > /etc/systemd/system/wpa_supplicant@wlo1.service
[Unit]
Description=WPA supplicant daemon (interface.specific version)
Requires=sys-subsystem.net-devices-%i.device
After=sys-subsystem-net-devices-%i.device
Before=network.target
Wants=network.target

# NetworkManager users will probably want the dbus version instead.

[Service]
Type=simple
ExecStart=/usr/bin/wpa_supplicant -c /etc/wpa_supplicant/wpa_supplicant-%I.conf -i%I

[Install]
WantedBy=multi-user.target
EOF


# DNS resolution servers
cat << EOF > /etc/resolv.conf
# resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 208.67.220.220
EOF

# Stop network managers from overwriting the DNS server list
chattr +i /etc/resolv.conf

cat << EOF > /etc/wpa_supplicant/wpa_supplicant-wlo1.conf
# wpa_supplicant-wlo1.conf
ctrl_interface=/run/wpa_supplicant
ctrl_interface_group=wheel
update_config=1
network={
ssid="Nord_public"
key_mgmt=NONE
bssid=D4:68:4D:39:7E:DC
}
network={
ssid="Teddy"
psk="Vsetinma30000obyvatel"
}
network={
ssid="small kitty"
psk="kJp4Rasvkv5vkJp4Rasvkv5v"
}
EOF

cat << EOF > /etc/iptables/iptables.rules
# iptables.rules
# Generated by iptables-save v1.6.0 on Sat Jun 25 23:16:47 2016
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [1160:68423]
:TCP - [0:0]
:UDP - [0:0]
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m conntrack --ctstate INVALID -j DROP
-A INPUT -p icmp -m icmp --icmp-type 8 -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p udp -m conntrack --ctstate NEW -j UDP
-A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -m conntrack --ctstate NEW -j TCP
-A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
-A INPUT -p tcp -j REJECT --reject-with tcp-reset
-A INPUT -j REJECT --reject-with icmp-proto-unreachable
-A INPUT -p tcp -m tcp --dport 17500 -j REJECT --reject-with icmp-port-unreachable
COMMIT
# Completed on Sat Jun 25 23:16:47 2016
EOF

iptables-restore < /etc/iptables/iptables.rules
sudo systemctl enable systemd-networkd
sudo systemctl enable wpa_supplicant@wlo1.service
#sudo systemctl start systemd-networkd

echo "Configuration done. You can now exit chroot."
