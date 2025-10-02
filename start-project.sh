#!/bin/bash
#
# start-project.sh
# =================
# Script para inicializar un proyecto Odoo/Doodba con Copier.
# Configura entorno virtual, instala dependencias, verifica carpeta y ejecuta la plantilla.

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
        print_step "$tool" "Working $frame" "$YELLOW"
        sleep $delay
    done
    printf "\r\033[K"
}

# ===========================
# Virtualenv
# ===========================
print_step "Virtualenv" "Checking" "$YELLOW"
sleep 0.6
if [ -d "venv" ]; then
    print_result "Virtualenv" "Exists" "$GREEN"
else
    python3 -m venv venv &>/dev/null &
    pid=$!
    spinner "Virtualenv" $pid
    wait $pid
    if [ -d "venv" ]; then
        print_result "Virtualenv" "Created" "$GREEN"
    else
        print_result "Virtualenv" "Error" "$RED"
        exit 1
    fi
fi

# ===========================
# Requirements
# ===========================
if [ -f "requirements.txt" ]; then
    print_step "Requirements" "Installing" "$YELLOW"
    . venv/bin/activate >/dev/null 2>&1
    pip install -r requirements.txt &>/dev/null &
    pid=$!
    spinner "Requirements" $pid
    wait $pid
    if [ $? -eq 0 ]; then
        print_result "Requirements" "Installed" "$GREEN"
    else
        print_result "Requirements" "Error" "$RED"
        exit 1
    fi
else
    print_result "Requirements" "Missing" "$RED"
fi

# ===========================
# Carpeta app
# ===========================
print_step "App folder" "Checking" "$YELLOW"
sleep 0.6
if [ -d "app" ]; then
    print_result "App folder" "Exists" "$GREEN"
else
    mkdir -p app &>/dev/null &
    pid=$!
    spinner "App folder" $pid
    wait $pid
    if [ -d "app" ]; then
        print_result "App folder" "Created" "$GREEN"
    else
        print_result "App folder" "Error" "$RED"
        exit 1
    fi
fi

# ===========================
# YAML
# ===========================
YAML_FILE="$(pwd)/copier-answers.yml"
print_step "YAML file" "Checking" "$YELLOW"
sleep 0.6
if [ -f "$YAML_FILE" ]; then
    print_result "YAML file" "Found" "$GREEN"
else
    print_result "YAML file" "Missing" "$RED"
    exit 1
fi

# ===========================
# Copier
# ===========================
print_step "Copier" "Running" "$YELLOW"
copier copy gh:Tecnativa/doodba-copier-template ./app \
    --trust --data-file "$YAML_FILE" --vcs-ref=HEAD --defaults --force &>/dev/null &
pid=$!
spinner "Copier" $pid
wait $pid
if [ $? -eq 0 ]; then
    print_result "Copier" "Finished" "$GREEN"
else
    print_result "Copier" "Error" "$RED"
    exit 1
fi

# ===========================
# Cambio de directorio
# ===========================
cd app || exit 1
