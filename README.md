## SMB-SETUP

Automates the installation and minimal configuration of a Samba server on Linux.
The script handles package installation, basic configuration, and verifies the Samba services after setup.

---

## Features

- Detects your Linux distribution automatically
- Supports **Debian/Ubuntu-based** and **Arch-based** distributions
- Installs Samba and configures a public share (/srv/samba/Public)
- Checks network and service status to ensure the server works

---

## Installation 

1. Clone the repository

```bash
git clone https://github.com/kael70/Smb-setup.git 
cd smb-setup
```
2. Make the script executable

```bash
sudo chmod +x server.sh
```
3. Run the script as root

```bash
sudo ./server.sh
```
---

## Notes
- Only works on Linux with Arch or Debian-based distributions.
- Future updates may include support for other Linux distributions.
- The script will create a public Samba share accessible without a password. 

---

## Contributors
- kael70 -scripting, Samba configuration, linux tests.

---

## License
This project is under MIT License. Check the LICENSE file for more details.
