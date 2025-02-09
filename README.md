# Tor Installer for Kali Linux & Debian-based Systems

[![Kali Linux](https://img.shields.io/badge/Kali_Linux-Supported-557C94?logo=kali-linux)](https://www.kali.org/)  
[![Debian](https://img.shields.io/badge/Debian-Supported-A81D33?logo=debian)](https://www.debian.org/)  
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)  

A secure, one-command installer for Tor that automates installation, configuration, and cleanup. Optimized for **Kali Linux** with Debian compatibility fixes.  

---

## 🚀 Quick Start

### Installation  
# Direct install (Debian/Kali)
```bash
curl -sSL https://raw.githubusercontent.com/coco975/tor-installer/main/tor_script.sh | bash
```

# Or clone and run
```bash
git clone https://github.com/coco975/tor-installer.git
cd tor-installer
sudo chmod +x tor_script.sh
./tor_script.sh
```
## ✨ Features
Feature	Description
Official Tor Repo	Latest Tor versions from Tor Project (bypass outdated Kali packages)
Kali Fixes	Forces Debian bookworm compatibility for kali-rolling systems
Auto-Rollback	Restores system state on failure via backups in ~/tor_backup
## 🛠️ Usage
### Commands

### Install Tor
```bash
./tor_script.sh
```
### Restore system state
```bash
./tor_script.sh restore
```
### Full uninstall
```Bash
./tor_script.sh uninstall
```
## 🔐 Security
### GPG Key Verification
#### Tor Project's official key
```bash
Key Fingerprint: A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89
```
### Logging
### All actions are logged to:
_~/tor_install.log_

## 🐛 Kali Linux Optimization
Workflow Example
Install Tor:
```bash
./tor_script.sh
```
### Route traffic anonymously:
```bash
torsocks nmap -sT -Pn example.com
```
### Clean up post-operation:
```bash
./tor_script.sh uninstall
```
## 🔧 Troubleshooting
### Service Issues

### For non-systemd systems (e.g., Docker)
```bash
sudo /etc/init.d/tor start
```
### View logs
```bash
journalctl -u tor.service
```
### Repository Fixes
### Remove corrupted repo
```bash
sudo rm /etc/apt/sources.list.d/tor.list
sudo apt update
```
### Stop the Tor Service
```bash
sudo systemctl stop tor
```
### Start the Tor service
```bash
sudo systemctl stop tor
```
### Disable Tor from Starting at Boot (Optional)
### To prevent Tor from running on startup, disable it with:
```bash
sudo systemctl disable tor
```
## Verify Tor is Stopped or Running 
### Check if Tor is running with:
```bash
systemctl status tor
```
### 🤝 Contributing
Fork the repository

## Create a branch:
```bash
git checkout -b feature/your-feature
```
### Commit changes
```bash
git commit -m "Add your feature"
```
## 📜 License
### MIT License - See LICENSE for details.
# Ethical Use Only: For legal security research only.

















