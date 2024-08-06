#!/bin/bash
#
# Socks5.Conf.sh
# Author: github.com/20elias01
#
# This script is designed to simplify creating Socks5 config
#
# Supported operating systems: Tested on Ubuntu 22.04 - Hetznet
# Disclaimer:
# This script comes with no warranties or guarantees. Use it at your own risk.

# Define colors
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD_BLACK='\033[1;30m'
BOLD_RED='\033[1;31m'
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_BLUE='\033[1;34m'
BOLD_PURPLE='\033[1;35m'
BOLD_CYAN='\033[1;36m'
BOLD_WHITE='\033[1;37m'
BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_PURPLE='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'
LIGHT_GREEN='\033[1;32m'
DARK_GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to display ASCII art
display_ascii_art() {
    clear
    local COLORS=("\033[31m" "\033[91m" "\033[33m" "\033[93m" "\033[32m" "\033[36m" "\033[34m" "\033[35m")
    local NC="\033[0m"  # No Color

    local num_colors=${#COLORS[@]}
    local line_num=0

    while IFS= read -r line; do
        local color_index=$((line_num % num_colors))
        echo -e "${COLORS[color_index]}$line${NC}"
        ((line_num++))
    done << "EOF"
            ██████████    █████           ███                                    
           ░░███░░░░░█   ░░███           ░░░                                     
            ░███  █ ░     ░███           ████      ██████       █████            
            ░██████       ░███          ░░███     ░░░░░███     ███░░             
            ░███░░█       ░███           ░███      ███████    ░░█████            
            ░███ ░   █    ░███      █    ░███     ███░░███     ░░░░███           
            ██████████    ███████████    █████   ░░████████    ██████            
           ░░░░░░░░░░    ░░░░░░░░░░░    ░░░░░     ░░░░░░░░    ░░░░░░           
    
  -----------   █████   █████    ███████████     ██████   █████                
  |  Socks5 |  ░░███   ░░███    ░░███░░░░░███   ░░██████ ░░███                 
  |         |   ░███    ░███     ░███    ░███    ░███░███ ░███                 
  |  Conf   |   ░███    ░███     ░██████████     ░███░░███░███                 
  -----------   ░░███   ███      ░███░░░░░░      ░███ ░░██████                 
                 ░░░█████░       ░███            ░███  ░░█████                 
                   ░░███         █████           █████  ░░█████                
                    ░░░         ░░░░░           ░░░░░    ░░░░░                 

EOF
}

# Function to Create New Configuration
Create_New_Configuration() {
    clear
    echo -e "${BOLD_BLUE}=================================================${NC}"
    echo -e "${BOLD_BLUE}            Create New Socks5 Config             ${NC}"
    echo -e "${BOLD_BLUE}=================================================${NC}"
    echo ""
    echo -e "${BOLD_GREEN}Creating Socks5 config.${NC}"

    # Update package repositories and install V2Ray
    sudo apt update
    bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
    sudo useradd --no-create-home --shell /usr/sbin/nologin v2ray

    # Write the new configuration file
    sudo bash -c "cat > /etc/systemd/system/v2ray.service <<EOF
[Unit]
Description=V2Ray Service
After=network.target

[Service]
ExecStart=/usr/local/bin/v2ray -config /usr/local/etc/v2ray/config.json
Restart=on-failure
User=v2ray

[Install]
WantedBy=multi-user.target
EOF"

    # Write the new configuration file
    sudo bash -c "cat > /usr/local/etc/v2ray/config.json <<EOF
{
  \"inbounds\": [
    {
      \"port\": 1080,
      \"listen\": \"0.0.0.0\",
      \"protocol\": \"socks\",
      \"settings\": {
        \"auth\": \"noauth\",
        \"udp\": true
      }
    }
  ],
  \"outbounds\": [
    {
      \"protocol\": \"freedom\",
      \"settings\": {}
    }
  ]
}
EOF"

    # Configure firewall
    sudo ufw allow 1080/tcp

    # Restart the service
    sudo systemctl daemon-reload
    sudo systemctl start v2ray
    sudo systemctl enable v2ray

    # Display completion message
    clear
    echo ""
    echo -e "${BOLD_GREEN}Configuration completed and service started.${NC}"
    echo ""
    echo -e "${CYAN}Port is (1080).${NC}"
    echo ""
    read -p "$(echo -e "${GREEN}Press Enter to continue...${NC}")" -s
}

# Function to View Status
View_status() {
    clear
    echo -e "${BOLD_BLUE}=================================================${NC}"
    echo -e "${BOLD_BLUE}              View Services Status                  ${NC}"
    echo -e "${BOLD_BLUE}=================================================${NC}"
    echo ""

    # Show the status of the V2Ray service
    sudo systemctl status v2ray --no-pager
    echo ""
    echo ""
    read -p "$(echo -e "${GREEN}Press Enter to continue...${NC}")" -s
}

# Function to Delete Configuration
Delete() {
    clear
    echo -e "${BOLD_RED}=================================================${NC}"
    echo -e "${BOLD_RED}                  Delete Config                 ${NC}"
    echo -e "${BOLD_RED}=================================================${NC}"
    echo ""

    # Stop the V2Ray service
    sudo systemctl stop v2ray

    # Remove the configuration files
    if [ -f /usr/local/etc/v2ray/config.json ]; then
        sudo rm /usr/local/etc/v2ray/config.json
    fi

    if [ -f /etc/systemd/system/v2ray.service ]; then
        sudo rm /etc/systemd/system/v2ray.service
    fi

    # Remove V2Ray
    bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh) --remove

    # Reload systemd to apply changes
    sudo systemctl daemon-reload

    # Display completion message
    echo -e "${BOLD_GREEN}Socks5 configuration has been removed.${NC}"
    echo ""
    echo ""
    read -p "$(echo -e "${GREEN}Press Enter to continue...${NC}")" -s
}

# Main menu
while true; do
    display_ascii_art
    echo -e "1. ${BOLD_GREEN}Create New Configuration${NC}"
    echo -e "2. ${CYAN}View status${NC}"
    echo -e "3. ${RED}Delete${NC}"
    echo -e "0. ${BOLD_PURPLE}Exit${NC}"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            Create_New_Configuration
            ;;
        2)
            View_status
            ;;
        3)
            Delete
            ;;
        0)
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
done