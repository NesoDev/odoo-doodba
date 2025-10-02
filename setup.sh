#!/bin/bash

# Colores
GREEN="\e[92m"
RED="\e[91m"
YELLOW="\033[1;33m"
WHITE="\033[0;37m"
NC="\033[0m"

# Imprime el paso actual (amarillo)
show_active() {
    local tool=$1
    local status=$2
    echo -ne "\r${YELLOW}[${tool}]...................${status}${NC}"
}

# Reemplaza el paso (blanco + resultado verde/rojo)
finalize_step() {
    local tool=$1
    local status=$2
    local color_result

    if [[ "$status" == "Installed" ]]; then
        color_result="${GREEN}${status}${NC}"
    elif [[ "$status" == Error* ]]; then
        color_result="${RED}${status}${NC}"
    else
        color_result="${WHITE}${status}${NC}"
    fi

    # Borrar la línea actual y reemplazar con versión final
    echo -ne "\r${WHITE}[${tool}]...................${color_result}${NC}\n"
}

### --- Docker --- ###
show_active "Docker" "Checking"
if command -v docker &> /dev/null; then
    finalize_step "Docker" "Installed"
else
    show_active "Docker" "Installing"
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
if command -v docker-compose &> /dev/null; then
    finalize_step "Docker Compose" "Installed"
else
    show_active "Docker Compose" "Installing"
    if curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose \
        && chmod +x /usr/local/bin/docker-compose; then
        finalize_step "Docker Compose" "Installed"
    else
        finalize_step "Docker Compose" "Error Install"
        exit 1
    fi
fi
