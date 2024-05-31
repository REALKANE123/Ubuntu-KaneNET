#!/bin/bash

# Set the location based on IP (Replace 'your_external_ip_api' with a valid IP-to-Location API)
location=$(curl -sSL https://ipinfo.io/city)-$(curl -sSL https://ipinfo.io/country)

# Set the hostname
hostname="KaneNET-$location"

# ANSI color codes
GREEN='\e[32m'
YELLOW='\e[33m'
RED='\e[31m'
CYAN='\e[36m'
NC='\e[0m' # No color

# Function to display stage with description and wait for 10 seconds
function display_stage {
  echo -e "${YELLOW}################ Stage: $1 - $2 ################${NC}"
  echo -e "${CYAN}$3${NC}"
  sleep 10
}

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run as root${NC}"
  exit
fi

# Custom welcome message for "KaneNET"
welcome_message="Welcome to KaneNET"
len_welcome=${#welcome_message}
len_location=${#location}
dashes_welcome=$(printf "%0.s#" $(seq 1 $len_welcome))
dashes_location=$(printf "%0.s#" $(seq 1 $len_location))
echo -e "${GREEN}$dashes_welcome${NC}"
echo -e "${GREEN}#${welcome_message}#${NC}"
echo -e "${GREEN}$dashes_welcome${NC}"
echo -e "${CYAN}Located at the heart of KaneNET's $location${NC}"
echo -e "${GREEN}$dashes_location${NC}"

# Set the hostname
hostnamectl set-hostname $hostname

# Install necessary tools
display_stage "1" "Installing necessary tools" "This stage will install essential tools."

# Install Nano
echo -e "${CYAN}Installing Nano...${NC}"
apt update
apt install -y nano

# Install OpenSSH Server
echo -e "${CYAN}Installing OpenSSH Server...${NC}"
apt install -y openssh-server

# Install htop
echo -e "${CYAN}Installing htop...${NC}"
apt install -y htop

# Install smartmontools
echo -e "${CYAN}Installing smartmontools...${NC}"
apt install -y smartmontools

# Install nvme-cli
echo -e "${CYAN}Installing nvme-cli...${NC}"
apt install -y nvme-cli

# Edit MOTD
display_stage "2" "Updating MOTD" "This stage will add disk information to the MOTD."

# Disk usage and capacity
echo -e "${CYAN}Adding disk usage and capacity to MOTD...${NC}"
disk_usage=$(df -h / | awk 'NR==2{print $3}')
disk_capacity=$(df -h / | awk 'NR==2{print $2}')
echo "Disk Usage: $disk_usage / $disk_capacity" >> /etc/motd

# CPU and RAM information
display_stage "3" "Adding CPU and RAM info to MOTD" "This stage will add CPU and RAM information to the MOTD."

echo -e "${CYAN}Adding CPU and RAM information to MOTD...${NC}"
cpu_info=$(grep "model name" /proc/cpuinfo | head -n 1 | cut -d ":" -f 2)
ram_info=$(free -h | awk '/Mem/ {print $2}')
echo "CPU: $cpu_info" >> /etc/motd
echo "RAM: $ram_info" >> /etc/motd

# Change the user's password and email it
display_stage "4" "Changing user's password and sending email" "This stage will change the user's password to a random 10-character password and send it by email."

# Change the user's password
echo -e "${CYAN}Set user's password...${NC}"
echo -e "New password: $password" | passwd
echo "user:$password"

# Send the password by email (Replace with your email configuration)
echo -e "${CYAN}New password...${NC}"
echo "Your new password for $location is: $password"

# Countdown to system restart
display_stage "5" "System restart in 10 seconds" "System will restart in 10 seconds."

for ((i=10; i>=1; i--)); do
  echo -e "Restarting in ${YELLOW}$i${NC} seconds..."
  sleep 1
done

# Restart the system
display_stage "6" "Restarting the system" "This stage will restart the system."

echo -e "${RED}Restarting the system...${NC}"
reboot
