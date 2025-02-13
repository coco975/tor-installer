#!/bin/bash
# Tor Installer for Kali Linux/Debian (v2.1)
# GitHub: https://github.com/coco975/tor_script3.git

# Enable strict error handling
set -euo pipefail

# Variables
TOR_REPO_LIST="/etc/apt/sources.list.d/tor.list"
TOR_GPG_KEYRING="/usr/share/keyrings/tor-archive-keyring.gpg"
BACKUP_DIR="$HOME/tor_backup"
LOG_FILE="$HOME/tor_install.log"
PKG_STATE_FILE="$BACKUP_DIR/pkg_state.txt"
SUPPORTED_DISTRO="bookworm"
# Functions
exec > >(tee -a "$LOG_FILE") 2>&1

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

check_sudo() {
    if [ "$(id -u)" -eq 0 ]; then
        log "Error: This script should not be run as root. Please run as a regular user with sudo privileges."
        exit 1
    fi
    
    if ! sudo -v; then
        log "Error: User does not have sudo privileges."
        exit 1
    fi
}

backup() {
    log "Creating backup directory at $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"

    # Backup package states
    log "Backing up package states..."
    {
        dpkg -l | grep '^ii  tor' >/dev/null 2>&1 && echo "tor_pkg=installed" || echo "tor_pkg=not_installed"
        dpkg -l | grep '^ii  deb.torproject.org-keyring' >/dev/null 2>&1 && echo "keyring_pkg=installed" || echo "keyring_pkg=not_installed"
    } > "$PKG_STATE_FILE"

    # Backup repo files
    log "Backing up repository files..."
    for file in "$TOR_REPO_LIST" "$TOR_GPG_KEYRING"; do
        if [ -f "$file" ]; then
            log "Backing up $file"
            sudo cp "$file" "$BACKUP_DIR"
        else
            log "Creating absence marker for $file"
            touch "$BACKUP_DIR/$(basename "$file").absent"
        fi
    done
}

restore() {
    log "Starting restoration process..."
    
    # Restore package states
    if [ -f "$PKG_STATE_FILE" ]; then
        log "Restoring package states..."
        source "$PKG_STATE_FILE"
        
        if [[ "$tor_pkg" == "not_installed" ]] && dpkg -l | grep -q '^ii  tor'; then
            log "Removing tor package..."
            sudo apt-get remove --purge -y tor
        fi
        
        if [[ "$keyring_pkg" == "not_installed" ]] && dpkg -l | grep -q '^ii  deb.torproject.org-keyring'; then
            log "Removing tor keyring package..."
            sudo apt-get remove --purge -y deb.torproject.org-keyring
        fi
    fi

    # Restore repository files
    log "Restoring repository files..."
    for file in "$TOR_REPO_LIST" "$TOR_GPG_KEYRING"; do
        base_file=$(basename "$file")
        if [ -f "$BACKUP_DIR/$base_file" ]; then
            log "Restoring $file"
            sudo cp "$BACKUP_DIR/$base_file" "$file"
        elif [ -f "$BACKUP_DIR/$base_file.absent" ]; then
            log "Removing $file as it didn't exist previously"
            sudo rm -f "$file"
        fi
    done

    log "Cleaning up apt..."
    sudo apt-get update
    sudo apt-get autoremove -y
    sudo apt-get clean

    log "Restoration complete."
}

install_dependencies() {
    log "Checking for required dependencies..."
    for pkg in lsb-release curl gnupg; do
        if ! dpkg -l | grep -q "^ii  $pkg"; then
            log "Installing $pkg..."
            sudo apt-get install -y "$pkg"
        fi
    done
}

#!/bin/bash

# ... [Keep previous variables and functions unchanged] ...

install_tor() {
    log "Starting Tor installation..."
    
    install_dependencies

    # Check if we're in WSL and configure systemd
    if uname -a | grep -qi 'microsoft'; then
        log "Detected WSL environment"
        WSL_CONF="/etc/wsl.conf"
        
        # Backup existing wsl.conf
        if [ -f "$WSL_CONF" ]; then
            log "Backing up existing wsl.conf"
            sudo cp "$WSL_CONF" "$WSL_CONF.bak"
        fi

        # Add systemd configuration
        if ! grep -q '^\[boot\]' "$WSL_CONF" 2>/dev/null || ! grep -q '^systemd=true' "$WSL_CONF" 2>/dev/null; then
            log "Configuring WSL for systemd support"
            echo -e "\n[boot]\nsystemd=true" | sudo tee -a "$WSL_CONF" >/dev/null
            log "--------------------------------------------------"
            log "WSL configuration updated. You MUST restart WSL with:"
            log "1. Close this terminal"
            log "2. Run in PowerShell: wsl --shutdown"
            log "3. Restart WSL"
            log "4. Rerun this script after reboot"
            log "--------------------------------------------------"
            exit 0
        else
            log "Systemd already configured in wsl.conf"
        fi
    fi

    # ... [Keep previous GPG/repository/installation steps unchanged] ...

    log "Starting Tor service..."
    # Enhanced service management
    if command -v systemctl >/dev/null 2>&1 && systemctl --version >/dev/null 2>&1; then
        sudo systemctl start tor && sudo systemctl enable tor
        log "Tor service managed via systemd"
    elif [ -f /etc/init.d/tor ]; then
        sudo /etc/init.d/tor start
        log "Tor started via init.d"
    elif command -v tor >/dev/null 2>&1; then
        log "Starting Tor directly"
        sudo tor --runasdaemon 1
    else
        log "ERROR: Failed to start Tor through all methods"
        log "Try manual start with: tor --runasdaemon 0"
        exit 1
    fi

    # Verify Tor is running
    if pgrep -x "tor" >/dev/null; then
        log "Tor successfully running (PID: $(pgrep -x "tor"))"
    else
        log "WARNING: Tor process not found - may require manual start"
    fi

    log "Tor installation completed successfully."
}

# ... [Keep rest of script unchanged] ...
uninstall_tor() {
    log "Starting Tor uninstallation..."
    
    log "Stopping Tor service..."
    sudo systemctl stop tor

    log "Removing Tor packages..."
    sudo apt-get remove --purge -y tor deb.torproject.org-keyring

    log "Cleaning up repository files..."
    sudo rm -f "$TOR_REPO_LIST" "$TOR_GPG_KEYRING"

    log "Cleaning up apt..."
    sudo apt-get autoremove -y
    sudo apt-get clean

    log "Tor uninstallation completed successfully."
}

# Main script
check_sudo

if [[ "${1:-}" == "restore" ]]; then
    restore
    exit 0
elif [[ "${1:-}" == "uninstall" ]]; then
    uninstall_tor
    exit 0
fi

trap 'log "Error occurred - initiating rollback..."; restore; exit 1' ERR

log "Starting Tor installation process..."
backup
install_tor
log "Installation successful! To undo changes, run: $0 restore"
