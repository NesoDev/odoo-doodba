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

### --- Python3 --- ###
show_active "Python3" "Checking"
sleep 0.8
if command -v python3 &> /dev/null; then
    finalize_step "Python3" "Installed"
else
    show_active "Python3" "Installing"
    sleep 1
    if sudo apt update -y &> /dev/null \
        && sudo apt install -y python3 &> /dev/null; then
        finalize_step "Python3" "Installed"
    else
        finalize_step "Python3" "Error Install"
        exit 1
    fi
fi

### --- pip3 --- ###
show_active "pip3" "Checking"
sleep 0.8
if command -v pip3 &> /dev/null; then
    finalize_step "pip3" "Installed"
else
    show_active "pip3" "Installing"
    sleep 1
    if sudo apt update -y &> /dev/null \
        && sudo apt install -y python3-pip &> /dev/null; then
        finalize_step "pip3" "Installed"
    else
        finalize_step "pip3" "Error Install"
        exit 1
    fi
fi

### --- venv --- ###
show_active "python3.10-venv" "Checking"
sleep 0.8
if dpkg -s python3.10-venv &> /dev/null; then
    finalize_step "python3.10-venv" "Installed"
else
    show_active "python3.10-venv" "Installing"
    sleep 1
    if sudo apt install -y python3.10-venv &> /dev/null; then
        finalize_step "python3.10-venv" "Installed"
    else
        finalize_step "python3.10-venv" "Error Install"
        exit 1
    fi
fi

### --- Virtualenv --- ###
show_active "Virtualenv" "Checking"
sleep 0.8
if [ -d "venv" ]; then
    finalize_step "Virtualenv" "Installed"
else
    show_active "Virtualenv" "Creating"
    sleep 1
    if python3 -m venv venv &> /dev/null; then
        finalize_step "Virtualenv" "Installed"
    else
        finalize_step "Virtualenv" "Error Create"
        exit 1
    fi
fi
# Activar el entorno
source venv/bin/activate

### --- requirements.txt --- ###
show_active "Requirements" "Checking"
sleep 0.8
if [ -f "requirements.txt" ]; then
    show_active "Requirements" "Installing"
    sleep 1
    if pip3 install -r requirements.txt &> /dev/null; then
        finalize_step "Requirements" "Installed"
    else
        finalize_step "Requirements" "Error Install"
        exit 1
    fi
else
    finalize_step "Requirements" "No file"
fi

### --- Copier --- ###
show_active "Copier" "Checking"
sleep 0.8
if command -v copier &> /dev/null; then
    finalize_step "Copier" "Installed"
else
    show_active "Copier" "Installing"
    sleep 1
    if pip3 install copier &> /dev/null; then
        finalize_step "Copier" "Installed"
    else
        finalize_step "Copier" "Error Install"
        exit 1
    fi
fi
