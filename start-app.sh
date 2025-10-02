#!/bin/bash
#
# start-app.sh
# ===========================
# Script para iniciar proyecto Odoo/Doodba.
# Activa venv, entra a app, descarga repositorios,
# reconstruye Docker, inicializa DB sin demo y reinicia servicios.

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
# Activate virtualenv
# ===========================
if [ -d "venv" ]; then
    print_step "Virtualenv" "Activating" "$YELLOW"
    . venv/bin/activate >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        print_result "Virtualenv" "Activated" "$GREEN"
    else
        print_result "Virtualenv" "Error" "$RED"
        exit 1
    fi
else
    print_result "Virtualenv" "Missing" "$RED"
    exit 1
fi

# ===========================
# Enter app directory
# ===========================
if [ -d "app" ]; then
    cd app || exit 1
    print_result "App folder" "Entered" "$GREEN"
else
    print_result "App folder" "Missing" "$RED"
    exit 1
fi

# ===========================
# Git aggregate
# ===========================
print_step "Git Aggregate" "Running" "$YELLOW"
invoke git-aggregate &>/dev/null &
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
# Rebuild Docker image
# ===========================
print_step "Img Build" "Running" "$YELLOW"
invoke img-build --pull &>/dev/null &
pid=$!
spinner "Img Build" $pid
wait $pid
if [ $? -eq 0 ]; then
    print_result "Img Build" "Finished" "$GREEN"
else
    print_result "Img Build" "Error" "$RED"
    exit 1
fi

# ===========================
# Initialize database without demo
# ===========================
print_step "DB Init" "Running" "$YELLOW"
docker-compose run --rm odoo --without-demo=true --stop-after-init -i base &>/dev/null &
pid=$!
spinner "DB Init" $pid
wait $pid
if [ $? -eq 0 ]; then
    print_result "DB Init" "Finished" "$GREEN"
else
    print_result "DB Init" "Error" "$RED"
    exit 1
fi

# ===========================
# Restart services
# ===========================
print_step "Restart" "Running" "$YELLOW"
invoke restart &>/dev/null &
pid=$!
spinner "Restart" $pid
wait $pid
if [ $? -eq 0 ]; then
    print_result "Restart" "Finished" "$GREEN"
else
    print_result "Restart" "Error" "$RED"
    exit 1
fi

echo -e "${GREEN}All steps completed successfully!${NC}"
