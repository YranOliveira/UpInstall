#!/bin/bash
#
# Print banner art.

#######################################
# Print a board. 
# Globals:
#   BG_BROWN
#   NC
#   WHITE
#   CYAN_LIGHT
#   RED
#   GREEN
#   YELLOW
# Arguments:
#   None
#######################################

# Função para verificar e instalar pacotes necessários
check_dependencies() {
    local packages=("net-tools")
    local missing=()

    for pkg in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $pkg "; then
            missing+=("$pkg")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        print_info "Instalando dependências necessárias..."
        sudo apt-get update -qq > /dev/null 2>&1
        sudo apt-get install -qq -y "${missing[@]}" > /dev/null 2>&1
    fi
}

print_banner() {
    clear
    printf "\n\n"

    # Verificar dependências antes de continuar
    check_dependencies
    
    # Banner principal
    printf "${COLOR_BLUE}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║                   Instlador UpInstall                        ║
║                                                              ║
║                                                              ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    printf "${COLOR_NC}"
    sleep 0.2

    # Informações do sistema
    printf "\n${COLOR_YELLOW}Sistema:${COLOR_NC}\n"
    printf "${COLOR_WHITE}"
    printf "  • SO: $(lsb_release -d | cut -f2)\n"
    printf "  • Kernel: $(uname -r)\n"
    printf "  • Memória: $(free -h | awk '/^Mem:/ {print $2}') total\n"
    printf "  • CPU: $(lscpu | grep 'Model name' | cut -f2 -d ':' | sed 's/^[ \t]*//')\n"
    printf "${COLOR_NC}"

    # Verificação de portas
    printf "\n${COLOR_YELLOW}Portas em uso:${COLOR_NC}\n"
    check_port() {
        local port=$1
        if netstat -tuln | grep -q ":$port "; then
            printf "${COLOR_RED}Em uso${COLOR_NC}"
        else
            printf "${COLOR_GREEN}Livre${COLOR_NC}"
        fi
    }

    printf "  • 80: $(check_port 80)\n"
    printf "  • 443: $(check_port 443)\n"
    printf "  • 3000-3999: $(if netstat -tuln | grep -q ':3[0-9]\{3\} '; then printf "${COLOR_RED}Algumas em uso${COLOR_NC}"; else printf "${COLOR_GREEN}Livres${COLOR_NC}"; fi)\n"
    printf "  • 4000-4999: $(if netstat -tuln | grep -q ':4[0-9]\{3\} '; then printf "${COLOR_RED}Algumas em uso${COLOR_NC}"; else printf "${COLOR_GREEN}Livres${COLOR_NC}"; fi)\n"
    printf "  • 5000-5999: $(if netstat -tuln | grep -q ':5[0-9]\{3\} '; then printf "${COLOR_RED}Algumas em uso${COLOR_NC}"; else printf "${COLOR_GREEN}Livres${COLOR_NC}"; fi)\n"

    # Data e hora
    printf "\n${COLOR_YELLOW}Data e Hora:${COLOR_NC} $(date '+%d/%m/%Y %H:%M:%S')\n"
    printf "\n"
}

# Função para mostrar o menu principal
show_menu() {
    printf "\n${COLOR_WHITE} 💻 Bem vindo(a) ao Instalador! Selecione uma opção:${COLOR_NC}\n\n"
    
    local options=(
        "☕ Instalar Sistema"
        "🔄 Atualizar Sistema"
        "❌ Deletar Sistema"
        "🔒 Bloquear Sistema"
        "🔓 Desbloquear Sistema"
        "🔑 Alterar Domínio"
        "💾 Backup do Sistema"
    )
    
    for i in "${!options[@]}"; do
        printf "   ${COLOR_GREEN}[$i]${COLOR_NC} ${options[$i]}\n"
    done
    printf "\n"
}
