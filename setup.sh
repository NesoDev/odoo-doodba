#!/bin/bash
#
# setup.sh
# =========
# Script para preparar el entorno de Odoo/Doodba en un VPS.
# Verifica e instala dependencias necesarias: Docker, Docker Compose, Python3, Pip3, Python venv.

GREEN="\e[92m"
RED="\e[91m"
YELLOW="\e[93m"
WHITE="\e[97m"
NC="\033[0m"

print_step() {
    local tool=$1
    local status=$2
    local color=$3
    printf "\r${color}[%s]...................%s${NC}" "$tool" "$status"
}

print_result() {
    local tool=$1
    local result=$2
    local color=$3
    printf "\r${WHITE}[%s]...................[${color}%s${NC}${WHITE}]\n" "$tool" "$result"
}

spinner() {
    local tool=$1
    local pid=$2
    local frames='|/-\'
    local delay=0.1
    local i=0
    while kill -0 $pid 2>/dev/null; do
        local frame=${frames:i++%${#frames}:1}
        print_step "$tool" "Installing $frame" "$YELLOW"
        sleep $delay
    done
    printf "\r\033[K"
}

check_and_install() {
    local tool=$1
    local check_command=$2
    local install_command=$3

    print_step "$tool" "Checking" "$YELLOW"
    sleep 0.6

    if eval "$check_command" &>/dev/null; then
        print_result "$tool" "Installed" "$GREEN"
        return
    fi

    eval "$install_command" &>/dev/null &
    local pid=$!
    spinner "$tool" $pid
    wait $pid

    if eval "$check_command" &>/dev/null; then
        print_result "$tool" "Installed" "$GREEN"
    else
        print_result "$tool" "Error" "$RED"
        exit 1
    fi
}

check_and_install "Docker" "command -v docker" \
    "curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh && rm get-docker.sh"

check_and_install "Docker Compose" "command -v docker-compose" \
    "sudo curl -L 'https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)' -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose"

check_and_install "Python3" "command -v python3" \
    "sudo apt update && sudo apt install -y python3"

check_and_install "Pip3" "command -v pip3" \
    "sudo apt update && sudo apt install -y python3-pip"

check_and_install "Python venv" "python3 -m venv --help" \
    "sudo apt update && sudo apt install -y python3.10-venv"

print_step "Docker group" "Configuring" "$YELLOW"
sudo usermod -aG docker $USER
sleep 0.6
printf "\r\033[K"
print_result "Docker group" "Configured" "$GREEN"
exec newgrp docker
