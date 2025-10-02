#!/bin/bash

# Colores
GREEN="\e[92m"
RED="\e[91m"
YELLOW="\033[1;33m"
WHITE="\033[0;37m"
NC="\033[0m"

# Función para imprimir estado
print_step() {
    local tool=$1
    local status=$2
    local mode=$3

    if [ "$mode" = "active" ]; then
        # Paso actual en amarillo entero
        echo -e "${YELLOW}[${tool}]...................${status}${NC}"
    else
        # Paso terminado: nombre blanco + resultado verde/rojo
        local color=$WHITE
        local result=$status
        if [[ "$status" == "Installed" ]]; then
            result="${GREEN}${status}${NC}"
        elif [[ "$status" == Error* ]]; then
            result="${RED}${status}${NC}"
        fi
        echo -e "${color}[${tool}]...................${result}${NC}"
    fi
}

### --- Docker --- ###
print_step "Docker" "Checking" "active"
if command -v docker &> /dev/null; then
    print_step "Docker" "Installed" "done"
else
    print_step "Docker" "Installing" "active"
    if curl -fsSL https://get.docker.com -o get-docker.sh \
        && sh get-docker.sh &> /dev/null \
        && rm get-docker.sh; then
        print_step "Docker" "Installed" "done"
    else
        print_step "Docker" "Error Install" "done"
        exit 1
    fi
fi

### --- Docker Compose --- ###
print_step "Docker Compose" "Checking" "active"
if command -v docker-compose &> /dev/null; then
    print_step "Docker Compose" "Installed" "done"
else
    print_step "Docker Compose" "Installing" "active"
    if curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose \
        && chmod +x /usr/local/bin/docker-compose; then
        print_step "Docker Compose" "Installed" "done"
    else
        print_step "Docker Compose" "Error Install" "done"
        exit 1
    fi
fi
