#!/bin/bash

#Colors of messages
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
RESET="\e[0m"

#Force user to run command as sudo
if [[ $EUID -ne 0 ]]; then
	echo -e "${RED}Must be root. Use sudo.${RESET}"
	exit 1
fi

#Test connectivity
if ! ping -c 1 -q 8.8.8.8 &>/dev/null; then
	echo -e "${RED}Verify your network.${RESET}"
	exit 1
fi

#Check Os and Linux version

if [[ -f /etc/os-release ]]; then
	. /etc/os-release
else
	echo -e "${RED}Can't detect Linux distribution.\nExit process${RESET}"
	exit 1
fi


if [[ "$ID" == "arch" || "$ID_LIKE" == *"arch" ]]; then
	PACKAGE_MANAGER="pacman"
elif [[ "$ID" == "debian" || "$ID" == "ubuntu" ||"$ID_LIKE" == *"debian" ]]; then
	PACKAGE_MANAGER="apt"
else
	echo -e "${RED}Non-supported distro!\nMust be Arch or Debian based system!${RESET}"
	exit 1
fi

echo -e "${BLUE}Distro: $NAME${RESET}"
echo -e "${BLUE}Package manager: $PACKAGE_MANAGER${RESET}"

install_samba() {
	echo -e "\nDownloading Samba..."
	if [[ "$PACKAGE_MANAGER" == "pacman" ]]; then
		pacman -Sy --noconfirm samba
	elif [[ "$PACKAGE_MANAGER" == "apt" ]]; then
		apt update
		apt install -y samba
	fi

	if [[ $? -ne 0 ]]; then
		echo -e "${RED}Installation failed.\nCheck your network and try again.${RESET}"
		exit 1
	fi
	echo "${GREEN}Installation complete${RESET}"
}
configure_samba() {
	echo -e "\nConfiguring Samba..."
	mkdir -p /srv/samba/Public
	chmod -R 0777 /srv/samba/Public
	cp /etc/samba/smb.conf /etc/samba/smb.conf.backup

	cat <<EOL> /etc/samba/smb.conf

	[Global]
		workgroup = WORKGROUP
		server string = Smb Server
		security = user
		map to guest = Bad User

	[Public]
		path = /srv/samba/Public
		writable = yes
		guest ok = yes
		read only = no
EOL
}
configure_samba
if [[ $PACKAGE_MANAGER=="pacman" ]]; then
	systemctl restart smbd
	systemctl restart nmbd

elif [[ $PACKAGE_MANAGER=="apt" ]]; then
	systemctl restart smb
	systemctl restart nmb
fi

if systemctl is-active --quiet smbd; then
	echo -e "${GREEN}[OK] samba services working.${RESET}"
else
	echo -e "${RED}[ERROR] samba services not working.${RESET}"
	exit 1
fi

if smbclient -L localhost -N > /dev/null 2>&1; then
	echo -e "${GREEN}[OK] Samba shares accessible${RESET}"
else
	echo -e "${RED}[ERROR] Samba shares inaccessible${RESET}"
	exit 1
fi

echo -e "\n${GREEN}Setup complete${RESET}"
echo -e "Share access: \\\\$(hostname -I | awk '{print $1}')\\Public"
