#!/bin/bash

# Usage: ./setup_scraper.sh [scraper_host_ip] [program_name]
# Example: ./setup_scraper.sh 192.168.1.6 submarine

# Check for required arguments
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 [scraper_host_ip] [program_name]"
    exit 1
fi

# Variables
scraperhost=$1
prog=$2
remote_dir="/var/lib/scraper"
local_mount_point="/var/lib/scraper"

# Function to check if passwordless SSH is set up
check_ssh_connection() {
    ssh -o BatchMode=yes -o ConnectTimeout=5 ${scraperhost} 'echo 2>&1' && return 0 || return 1
}

# Check if sshfs is installed
if ! command -v sshfs >/dev/null 2>&1; then
    echo "sshfs is not installed. Please install it first."
    exit 1
fi

# Check if SSH key exists; if not, generate one
if [ ! -f "$HOME/.ssh/id_rsa.pub" ]; then
    echo "SSH key not found. Generating one..."
    ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N ""
fi

# Check if passwordless SSH is set up
echo "Checking if passwordless SSH is configured to ${scraperhost}..."
if check_ssh_connection; then
    echo "Passwordless SSH is already set up."
else
    echo "Passwordless SSH is not configured. Setting it up..."
    echo "You may be prompted for your password on the scraper host."

    # Copy the SSH key to the scraper host
    ssh-copy-id ${scraperhost}

    # Verify if passwordless SSH is now set up
    if check_ssh_connection; then
        echo "Passwordless SSH has been successfully configured."
    else
        echo "Failed to configure passwordless SSH. Please check your SSH settings."
        exit 1
    fi
fi

# Create the local /var/lib/scraper directory if it doesn't exist
if [ ! -d "${local_mount_point}" ]; then
    echo "Creating /var/lib/scraper directory..."
    sudo mkdir -p "${local_mount_point}"
    # Change ownership to the current user
    sudo chown $USER "${local_mount_point}"
    sudo chmod 755 "${local_mount_point}"
fi

# Check if already mounted
if mountpoint -q "${local_mount_point}"; then
    echo "${local_mount_point} is already mounted."
else
    # Mount the scraper's /var/lib/scraper directory over sshfs
    echo "Mounting remote scraper directory..."
    sshfs -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3 ${USER}@${scraperhost}:${remote_dir} "${local_mount_point}"

    if [ $? -ne 0 ]; then
        echo "Failed to mount remote scraper directory."
        exit 1
    fi
fi

# Create the program-specific dump directory
echo "Creating program-specific dump directory..."
mkdir -p "${local_mount_point}/dump/${prog}"
# Removed chmod command

echo "Setup complete. You can now drop URLs into ${local_mount_point}/pool."
