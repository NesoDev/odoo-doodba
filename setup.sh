#!/bin/bash

# Colores
GREEN="\e[92m"
RED="\e[91m"
YELLOW="\033[1;33m"
WHITE="\033[0;37m"
NC="\033[0m"

# Mostrar paso actual (amarillo)
show_active() {
    local tool=$1
    local status=$2
    echo -ne "\r${YELLOW}[${tool}]...................${status}${NC}"
}

# Finalizar paso (blanco + resultado verde/rojo)
finalize_step() {
    local tool=$1
    local status=$2
    local result

    if [[ "$status" == "Installed" ]]; then
        result="${GREEN}${status}${NC}"
    elif [[ "$status" == Error* ]]; then
        result="${RED}${status}${NC}"
    else
        result="${WHITE}${status}${NC}"
    fi

    # Borra todo y muestra limpio
    echo -ne "\r\033[K${WHITE}[${tool}]...................${result}\n"
}

### --- Docker --- ###
show_active "Docker" "Checking"
sleep 0.8
if command -v docker &> /dev/null; then
    finalize_step "Docker" "Installed"
else
    show_active "Docker" "Installing"
    sleep 1
    if curl -fsSL https://get.docker.com -o get-docker.sh \
        && sh get-docker.sh &> /dev/null \
        && rm get-docker.sh; then
        finalize_step "Docker" "Installed"
    else
        finalize_step "Docker" "Error Install"
        exit 1
    fi
fi

### --- Docker Compose --- ###
show_active "Docker Compose" "Checking"
sleep 0.8
if command -v docker-compose &> /dev/null; then
    finalize_step "Docker Compose" "Installed"
else
    show_active "Docker Compose" "Installing"
    sleep 1
    if sudo curl -sL "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose \
        && sudo chmod +x /usr/local/bin/docker-compose; then
        finalize_step "Docker Compose" "Installed"
    else
        finalize_step "Docker Compose" "Error Install"
        exit 1
    fi
fi
