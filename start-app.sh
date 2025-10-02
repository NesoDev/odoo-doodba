#!/bin/bash
#
# start-app.sh
# ===========================
# Script para inicializar y ejecutar un proyecto Odoo/Doodba.
# Descarga repositorios, reconstruye imágenes Docker, crea base de datos
# y reinicia los servicios.

GREEN="\e[92m"
RED="\e[91m"
YELLOW="\e[93m"
WHITE="\e[97m"
NC="\033[0m"

print_step() {
    local tool=$1
    local status=$2
    local color=$3
    printf "\r${color}[%s]....................%s${NC}" "$tool" "$status"
}

print_result() {
    local tool=$1
    local result=$2
    local color=$3
    printf "\r${WHITE}[%s]....................[${color}%s${NC}${WHITE}]\n" "$tool" "$result"
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
# Git Aggregate
# ===========================
print_step "Git Aggregate" "Running" "$YELLOW"
invoke git-aggregate
pid=$!
spinner "Git Aggregate" $pid
wait $pid
if [ $? -eq 0 ]; then
    print_result "Git Aggregate" "Finished" "$GREEN"
else
    print_result "Git Aggregate" "Error" "$RED"
    exit 1
fi

# ===========================
# Docker Build
# ===========================
print_step "Docker Build" "Running" "$YELLOW"
invoke img-build --pull &>/dev/null &
pid=$!
spinner "Docker Build" $pid
wait $pid
if [ $? -eq 0 ]; then
    print_result "Docker Build" "Finished" "$GREEN"
else
    print_result "Docker Build" "Error" "$RED"
    exit 1
fi

# ===========================
# Base de datos sin demo
# ===========================
print_step "DB Init" "Running" "$YELLOW"
docker compose run --rm odoo --without-demo=true --stop-after-init -i base &>/dev/null &
pid=$!
spinner "DB Init" $pid
wait $pid
if [ $? -eq 0 ]; then
    print_result "DB Init" "Created" "$GREEN"
else
    print_result "DB Init" "Error" "$RED"
    exit 1
fi

# ===========================
# Restart services
# ===========================
print_step "Restart Services" "Running" "$YELLOW"
invoke restart &>/dev/null &
pid=$!
spinner "Restart Services" $pid
wait $pid
if [ $? -eq 0 ]; then
    print_result "Restart Services" "Finished" "$GREEN"
else
    print_result "Restart Services" "Error" "$RED"
    exit 1
fi
